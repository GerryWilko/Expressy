//
//  EXTInteractionDetector.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 12/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class EXTInteractionDetector {
    /// Value for current force in G.
    var currentForce:Float
    /// Value for current roll in degrees.
    var currentRoll:Float
    /// Value for current pitch in degrees.
    var currentPitch:Float
    /// Value denoting if the user has touched down.
    var touchedDown:Bool
    /// Value denoting if detection is currently active.
    var detecting:Bool
    
    fileprivate var lastDataTime:TimeInterval!
    
    fileprivate var metricsCallbacks:Array<(_ data:Float?) -> Void>
    fileprivate var duringMetricsCallbacks:Array<(_ data:Float?) -> Void>
    fileprivate var postMetricsCallbacks:Array<(_ data:Float?) -> Void>
    fileprivate var flickCallbacks:Array<(_ data:Float?) -> Void>
    fileprivate var noFlickCallBacks:Array<(_ data:Float?) -> Void>
    fileprivate var hardPressCallbacks:Array<(_ data:Float?) -> Void>
    fileprivate var mediumPressCallbacks:Array<(_ data:Float?) -> Void>
    fileprivate var softPressCallbacks:Array<(_ data:Float?) -> Void>
    fileprivate var allPressCallbacks:Array<(_ data:Float?) -> Void>
    
    fileprivate let dataCache:SensorCache
    fileprivate let medForceThreshold:Float = 0.2
    fileprivate let hardForceThreshold:Float = 0.5
    fileprivate let flickThreshold:Float = 0.5
    
    /// Initialises a new InteractionDetector analysing sensor data from the provided data cache.
    /// - parameter Sensor: data cache to be used.
    /// - returns: InteractionDetector instance.
    init(dataCache:SensorCache) {
        self.dataCache = dataCache
        
        currentForce = 0.0
        currentRoll = 0.0
        currentPitch = 0.0
        touchedDown = false
        detecting = false
        
        metricsCallbacks = Array<(_ data:Float?) -> Void>()
        duringMetricsCallbacks = Array<(_ data:Float?) -> Void>()
        postMetricsCallbacks = Array<(_ data:Float?) -> Void>()
        flickCallbacks = Array<(_ data:Float?) -> Void>()
        noFlickCallBacks = Array<(_ data:Float?) -> Void>()
        hardPressCallbacks = Array<(_ data:Float?) -> Void>()
        mediumPressCallbacks = Array<(_ data:Float?) -> Void>()
        softPressCallbacks = Array<(_ data:Float?) -> Void>()
        allPressCallbacks = Array<(_ data:Float?) -> Void>()
        
        lastDataTime = Date.timeIntervalSinceReferenceDate
        
        dataCache.subscribe(dataCallback)
    }
    
    deinit {
        stopDetection()
        dataCache.clearSubscriptions()
        clearSubscriptions()
    }
    
    /// Initiates detection by subscribing to data callbacks from SensorProcessor.
    func startDetection() {
        detecting = true
    }
    
    /// Internal function for processing of data callbacks from SensorProcessor.
    /// - parameter data: Sensor data recieved from sensor.
    fileprivate func dataCallback(_ data:SensorData) {
        if (!detecting) { return }
        
        currentForce = calculateForce(data)
        currentRoll = calculateRoll(data)
        currentPitch = calculatePitch(data)
        
        lastDataTime = data.time
        fireMetrics()
        
        if (touchedDown){
            fireDuringMetrics()
        } else {
            firePostMetrics()
        }
    }
    
    /// Stops detection by unsubscribing from SensorProcessor and clearing subscriptions to InteractionDetector.
    func stopDetection() {
        detecting = false
    }
    
    /// Function for passing touch down events, used for detection of touch down related events and calcuation of continous interactions (roll, pitch).
    /// - parameter touchDownTime: Time touch down event occured.
    func touchDown() {
        if (!detecting) { return }
        
        let touchDownTime = Date.timeIntervalSinceReferenceDate
        
        touchedDown = true
        currentRoll = 0.0
        currentPitch = 0.0
        
        let touchForce = calculateTouchForce(touchDownTime)
        let data = dataCache.getForTime(touchDownTime)
        data.touchDown(touchForce)
        
        fireAllPress(touchForce)
        
        if (touchForce > hardForceThreshold) {
            fireHardPress(touchForce)
        } else if (touchForce > medForceThreshold) {
            fireMediumPress(touchForce)
        } else {
            fireSoftPress(touchForce)
        }
    }
    
    /// Function for passing touch up events, used for detection of touch up related events.
    /// - parameter touchUpTime: Time touch up event occured.
    func touchUp() {
        if (!detecting) { return }
        
        let touchUpTime = Date.timeIntervalSinceReferenceDate
        
        touchedDown = false
        currentRoll = 0.0
        currentPitch = 0.0
        
        let data = dataCache.getForTime(touchUpTime)
        data.touchUp()
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(EXTInteractionDetector.touchEndCallback(_:)), userInfo: touchUpTime, repeats: false)
    }
    
    /// Function for informing of cancelled touch event.
    func touchCancelled() {
        if (!detecting) { return }
        
        touchedDown = false
        currentRoll = 0.0
        currentPitch = 0.0
    }
    
    /// Timer callback function for detection of events after touch up event.
    /// - parameter timer: Timer that fired.
    @objc fileprivate func touchEndCallback(_ timer:Timer) {
        let touchUpTime = timer.userInfo as! TimeInterval
        let end = Date.timeIntervalSinceReferenceDate
        
        let flickForce = calculateFlickForce(touchUpTime, end: end)
        
        if (flickForce > flickThreshold) {
            fireFlick(flickForce)
        } else {
            fireNoFlick(flickForce)
        }
        
        let data = dataCache.getForTime(touchUpTime)
        data.setFlick(flickForce)
    }
    
    /// Internal function for calculation of rotation changes based upon new sensor data and time since last reading.
    /// - parameter Sensor: data to be analysed.
    /// - returns: New calculation for rotation from touch down.
    fileprivate func calculateRoll(_ data:SensorData) -> Float {
        var totalRotation = currentRoll
        
        totalRotation += data.gyro.x * Float(TimeInterval(data.time - lastDataTime))
        
        return totalRotation
    }
    
    /// Internal function for calculation of pitch changes based upon new sensor data and time since last reading.
    /// - parameter Sensor: data to be analysed.
    /// - returns: New calcuation for pitch from touch down.
    fileprivate func calculatePitch(_ data:SensorData) -> Float {
        var totalPitch = currentPitch
        
        totalPitch += data.gyro.y * Float(TimeInterval(data.time - lastDataTime))
        
        return totalPitch
    }
    
    /// Internal function for calculation of instantaneous force based upon new sensor data and time since last reading.
    /// - parameter Sensor: data to be analysed.
    /// - returns: New calculation for instantaneous force.
    fileprivate func calculateForce(_ data:SensorData) -> Float {
        return data.linAcc.magnitude()
    }
    
    func calculateTouchForce(_ touchDownTime:TimeInterval) -> Float {
        let data = dataCache.getRangeForTime(touchDownTime - 0.1, end: touchDownTime)
        
        var force:Float = 0.0
        
        for d in data {
            if d.linAcc.magnitude() > force {
                force = d.linAcc.magnitude()
            }
        }
        
        return force
    }
    
    /// Internal function for calculation of flick force after the touch up event.
    /// - parameter touchUpTime: Time touch up event occured.
    /// - parameter end: End time of window for analysis.
    /// - returns: New calculation of flick force.
    fileprivate func calculateFlickForce(_ touchUpTime:TimeInterval, end:TimeInterval) -> Float {
        let data = dataCache.getRangeForTime(touchUpTime, end: end)
        
        var maxMag:Float = 0.0
        
        for d in data {
            if (d.linAcc.magnitude() > maxMag) {
                maxMag = d.linAcc.magnitude()
            }
        }
        
        return maxMag
    }
    
    /// Internal function to fire metric callbacks.
    fileprivate func fireMetrics() {
        fireCallbacks(nil, callbacks: metricsCallbacks)
    }
    
    /// Internal function to fire during metric callbacks.
    fileprivate func fireDuringMetrics() {
        fireCallbacks(nil, callbacks: duringMetricsCallbacks)
    }
    
    /// Internal function to fire post metric callbacks.
    fileprivate func firePostMetrics() {
        fireCallbacks(nil, callbacks: postMetricsCallbacks)
    }
    
    /// Internal function to fire flick callbacks.
    /// - parameter data: Value representing flicked force.
    fileprivate func fireFlick(_ data:Float) {
       fireCallbacks(data, callbacks: flickCallbacks)
    }
    
    /// Internal function to fire no flick callbacks.
    /// - parameter data: Value representing flicked force.
    fileprivate func fireNoFlick(_ data:Float) {
        fireCallbacks(data, callbacks: noFlickCallBacks)
    }
    
    /// Internal function to fire hard press callbacks.
    /// - parameter data: Value representing touch force.
    fileprivate func fireHardPress(_ data:Float) {
        fireCallbacks(data, callbacks: hardPressCallbacks)
    }
    
    /// Internal function to fire medium press callbacks.
    /// - parameter data: Value representing touch force.
    fileprivate func fireMediumPress(_ data:Float) {
        fireCallbacks(data, callbacks: mediumPressCallbacks)
    }
    
    /// Internal function to fire soft press callbacks.
    /// - parameter data: Value representing touch force.
    fileprivate func fireSoftPress(_ data:Float) {
        fireCallbacks(data, callbacks: softPressCallbacks)
    }
    
    /// Internal function to fire all press callbacks.
    /// - parameter data: Value representing touch force.
    fileprivate func fireAllPress(_ data:Float) {
        fireCallbacks(data, callbacks: allPressCallbacks)
    }
    
    /// Internal function to fire a set of callbacks.
    /// - parameter data: Data to be passed to callbacks.
    /// - parameter callbacks: Set of callbacks to be fired.
    fileprivate func fireCallbacks(_ data:Float?, callbacks:[(_ data:Float?) -> Void]) {
        for cb in callbacks {
            cb(data)
        }
    }
    
    /// Event subscription system, subscribing to defined events causes callback to be fired when specified event occurs.
    /// - parameter event: Type of event to be subscribed.
    /// - parameter callback: Function with data parameter to be called on event occurence.
    func subscribe(_ event:EXTEvent, callback:@escaping (_ data:Float?) -> Void) {
        switch event {
        case .metrics:
            metricsCallbacks.append(callback)
        case .duringMetrics:
            duringMetricsCallbacks.append(callback)
        case .postMetrics:
            postMetricsCallbacks.append(callback)
        case .flick:
            flickCallbacks.append(callback)
        case .noFlick:
            noFlickCallBacks.append(callback)
        case .hardPress:
            hardPressCallbacks.append(callback)
        case .mediumPress:
            mediumPressCallbacks.append(callback)
        case .softPress:
            softPressCallbacks.append(callback)
        case .allPress:
            allPressCallbacks.append(callback)
        }
    }
    
    /// Function to clear all current event subscriptions.
    func clearSubscriptions() {
        metricsCallbacks.removeAll()
        duringMetricsCallbacks.removeAll()
        postMetricsCallbacks.removeAll()
        flickCallbacks.removeAll()
        noFlickCallBacks.removeAll()
        hardPressCallbacks.removeAll()
        mediumPressCallbacks.removeAll()
        softPressCallbacks.removeAll()
        allPressCallbacks.removeAll()
    }
}

/// Enum for Event types.
/// - Metrics: Event fired each time continous metrics (force, roll, pitch) are updated.
/// - DuringMetrics: Event fired each time continous metrics are updated during touch interaction.
/// - PostMetrics: Event fired each time continous metrics are updated after a touch interaction.
/// - Flick: Event fired when a flick event occurs.
/// - NoFlick: Event fired when no flick event occurs.
/// - HardPress: Event fired when the screen is struck hard.
/// - MediumPress: Event fired when the screen is struck medium.
/// - SoftPress: Event fired when the screen is struck soft.
/// - AllPress: Event fired each time the screen is struck.
enum EXTEvent {
    case metrics, duringMetrics, postMetrics, flick, noFlick, hardPress, mediumPress, softPress, allPress
}
