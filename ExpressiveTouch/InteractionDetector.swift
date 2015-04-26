//
//  InteractionDetector.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class InteractionDetector {
    /// Value for current force in G.
    var currentForce:Float
    /// Value for current rotation in degrees.
    var currentRotation:Float
    /// Value for current pitch in degrees.
    var currentPitch:Float
    /// Value denoting if the user has touched down.
    var touchDown:Bool
    
    private var lastDataTime:NSTimeInterval!
    
    private var metricsCallbacks:Array<(data:Float!) -> Void>
    private var flickedCallbacks:Array<(data:Float!) -> Void>
    private var hardPressCallbacks:Array<(data:Float!) -> Void>
    private var mediumPressCallbacks:Array<(data:Float!) -> Void>
    private var softPressCallbacks:Array<(data:Float!) -> Void>
    
    private let dataCache:WaxCache
    private let touchForceFilter:Float = 0.1
    private let medForceThreshold:Float = 0.2
    private let hardForceThreshold:Float = 0.5
    private let flickThreshold:Float = 0.5
    
    /// Initialises a new InteractionDetector analysing sensor data from the provided data cache.
    /// :param: Sensor data cache to be used.
    /// :returns: InteractionDetector instance.
    init(dataCache:WaxCache) {
        self.dataCache = dataCache
        
        currentForce = 0.0
        currentRotation = 0.0
        currentPitch = 0.0
        touchDown = false
        
        metricsCallbacks = Array<(data:Float!) -> Void>()
        
        flickedCallbacks = Array<(data:Float!) -> Void>()
        hardPressCallbacks = Array<(data:Float!) -> Void>()
        mediumPressCallbacks = Array<(data:Float!) -> Void>()
        softPressCallbacks = Array<(data:Float!) -> Void>()
    }
    
    deinit {
        stopDetection()
    }
    
    /// Initiates detection by subscribing to data callbacks from WaxProcessor.
    func startDetection() {
        dataCache.subscribe(dataCallback)
    }
    
    /// Internal function for processing of data callbacks from WaxProcessor.
    /// :param: data Sensor data recieved from sensor.
    private func dataCallback(data:WaxData) {
        currentForce = calculateForce(data)
        
        if (touchDown) {
            currentRotation = calculateRotation(data)
            currentPitch = calculatePitch(data)
        }
        
        lastDataTime = data.time
        fireMetrics()
    }
    
    /// Stops detection by unsubscribing from WaxProcessor and clearing subscriptions to InteractionDetector.
    func stopDetection() {
        dataCache.clearSubscriptions()
        clearSubscriptions()
    }
    
    /// Function for passing touch down events, used for detection of touch down related events and calcuation of continous interactions (roll, pitch).
    /// :param: touchDownTime Time touch down event occured.
    func touchDown(touchDownTime:NSTimeInterval) {
        touchDown = true
        
        let touchForce = calculateTouchForce(touchDownTime)
        let data = dataCache.getForTime(touchDownTime)
        data.touchDown(touchForce)
        
        if (touchForce > hardForceThreshold) {
            fireHardPress(touchForce)
        } else if (touchForce > medForceThreshold) {
            fireMediumPress(touchForce)
        } else {
            fireSoftPress(touchForce)
        }
    }
    
    /// Function for passing touch up events, used for detection of touch up related events.
    /// :param: touchUpTime Time touch up event occured.
    func touchUp(touchUpTime:NSTimeInterval) {
        touchDown = false
        currentRotation = 0.0
        currentPitch = 0.0
        
        let data = dataCache.getForTime(touchUpTime)
        data.touchUp()
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("touchEndCallback:"), userInfo: touchUpTime, repeats: false)
    }
    
    /// Function for informing of cancelled touch event.
    func touchCancelled() {
        touchDown = false
    }
    
    /// Timer callback function for detection of events after touch up event.
    /// :param: timer Timer that fired.
    @objc private func touchEndCallback(timer:NSTimer) {
        let touchUpTime = timer.userInfo as! NSTimeInterval
        let end = NSDate.timeIntervalSinceReferenceDate()
        
        let flickForce = calculateFlickForce(touchUpTime, end: end)
        
        if (flickForce > flickThreshold) {
            fireFlicked(flickForce)
        }
    }
    
    /// Internal function for calculation of rotation changes based upon new sensor data and time since last reading.
    /// :param: Sensor data to be analysed.
    /// :returns: New calculation for rotation from touch down.
    private func calculateRotation(data:WaxData) -> Float {
        var totalRotation = currentRotation
        
        totalRotation += data.gyro.x * Float(NSTimeInterval(data.time - lastDataTime))
        
        return totalRotation
    }
    
    /// Internal function for calculation of pitch changes based upon new sensor data and time since last reading.
    /// :param: Sensor data to be analysed.
    /// :returns: New calcuation for pitch from touch down.
    private func calculatePitch(data:WaxData) -> Float {
        var totalPitch = currentPitch
        
        totalPitch += data.gyro.y * Float(NSTimeInterval(data.time - lastDataTime))
        
        return totalPitch
    }
    
    /// Internal function for calculation of instantaneous force based upon new sensor data and time since last reading.
    /// :param: Sensor data to be analysed.
    /// :returns: New calculation for instantaneous force.
    private func calculateForce(data:WaxData) -> Float {
        return data.getAccNoGrav().magnitude()
    }
    
    func calculateTouchForce(touchDownTime:NSTimeInterval) -> Float {
        let data = dataCache.getRangeForTime(touchDownTime - 0.1, end: touchDownTime)
        
        var force:Float = 0.0
        
        for d in data {
            if d.getAccNoGrav().magnitude() > force {
                force = d.getAccNoGrav().magnitude()
            }
        }
        
        return force
    }
    
    /// Internal function for calculation of flick force after the touch up event.
    /// :param: touchUpTime Time touch up event occured.
    /// :param: end End time of window for analysis.
    /// :returns: New calculation of flick force.
    private func calculateFlickForce(touchUpTime:NSTimeInterval, end:NSTimeInterval) -> Float {
        let data = dataCache.getRangeForTime(touchUpTime, end: end)
        
        var maxMag:Float = 0.0
        
        for d in data {
            if (d.getAccNoGrav().magnitude() > maxMag) {
                maxMag = d.getAccNoGrav().magnitude()
            }
        }
        
        return maxMag
    }
    
    /// Internal function to fire metric callbacks.
    private func fireMetrics() {
        fireCallbacks(nil, callbacks: metricsCallbacks)
    }
    
    /// Internal function to fire flicked callbacks.
    /// :param: data Value representing flicked force.
    private func fireFlicked(data:Float) {
       fireCallbacks(data, callbacks: flickedCallbacks)
    }
    
    /// Internal function to fire hard press callbacks.
    /// :param: data Value representing touch force.
    private func fireHardPress(data:Float) {
        fireCallbacks(data, callbacks: hardPressCallbacks)
    }
    
    /// Internal function to fire medium press callbacks.
    /// :param: data Value representing touch force.
    private func fireMediumPress(data:Float) {
        fireCallbacks(data, callbacks: mediumPressCallbacks)
    }
    
    /// Internal function to fire soft press callbacks.
    /// :param: data Value representing touch force.
    private func fireSoftPress(data:Float) {
        fireCallbacks(data, callbacks: softPressCallbacks)
    }
    
    /// Internal function to fire a set of callbacks.
    /// :param: data Data to be passed to callbacks.
    /// :param: callbacks Set of callbacks to be fired.
    private func fireCallbacks(data:Float!, callbacks:[(data:Float!) -> Void]) {
        for cb in callbacks {
            cb(data: data)
        }
    }
    
    /// Event subscription system, subscribing to defined events causes callback to be fired when specified event occurs.
    /// :param: event Type of event to be subscribed.
    /// :param: callback Function with data parameter to be called on event occurence.
    func subscribe(event:EventType, callback:(data:Float!) -> Void) {
        switch event {
        case .Metrics:
            metricsCallbacks.append(callback)
            break
        case .Flicked:
            flickedCallbacks.append(callback)
            break
        case .HardPress:
            hardPressCallbacks.append(callback)
            break
        case .MediumPress:
            mediumPressCallbacks.append(callback)
            break
        case .SoftPress:
            softPressCallbacks.append(callback)
            break
        default:
            NSException(name: "InvalidEvent", reason: "Invalid event subscription.", userInfo: nil).raise()
            break
        }
    }
    
    /// Function to clear all current event subscriptions.
    func clearSubscriptions() {
        metricsCallbacks.removeAll(keepCapacity: false)
        flickedCallbacks.removeAll(keepCapacity: false)
        hardPressCallbacks.removeAll(keepCapacity: false)
        mediumPressCallbacks.removeAll(keepCapacity: false)
        softPressCallbacks.removeAll(keepCapacity: false)
    }
}

/// Enum for Event types.
/// - Metrics: Event fired each time continous metrics (force, roll, pitch) are updated.
/// - Flicked: Event fired when a flick event occurs.
/// - HardPress: Event fired when the screen is struck hard.
/// - MediumPress: Event fired when the screen is struck medium.
/// - SoftPress: Event fired when the screen is struck soft.
enum EventType {
    case Metrics, Flicked, HardPress, MediumPress, SoftPress
}