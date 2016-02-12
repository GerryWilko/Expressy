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
    
    private var lastDataTime:NSTimeInterval!
    
    private var metricsCallbacks:Array<(data:Float?) -> Void>
    private var duringMetricsCallbacks:Array<(data:Float?) -> Void>
    private var postMetricsCallbacks:Array<(data:Float?) -> Void>
    private var flickCallbacks:Array<(data:Float?) -> Void>
    private var noFlickCallBacks:Array<(data:Float?) -> Void>
    private var hardPressCallbacks:Array<(data:Float?) -> Void>
    private var mediumPressCallbacks:Array<(data:Float?) -> Void>
    private var softPressCallbacks:Array<(data:Float?) -> Void>
    private var allPressCallbacks:Array<(data:Float?) -> Void>
    
    private let dataCache:SensorCache
    private let medForceThreshold:Float = 0.2
    private let hardForceThreshold:Float = 0.5
    private let flickThreshold:Float = 0.5
    
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
        
        metricsCallbacks = Array<(data:Float?) -> Void>()
        duringMetricsCallbacks = Array<(data:Float?) -> Void>()
        postMetricsCallbacks = Array<(data:Float?) -> Void>()
        flickCallbacks = Array<(data:Float?) -> Void>()
        noFlickCallBacks = Array<(data:Float?) -> Void>()
        hardPressCallbacks = Array<(data:Float?) -> Void>()
        mediumPressCallbacks = Array<(data:Float?) -> Void>()
        softPressCallbacks = Array<(data:Float?) -> Void>()
        allPressCallbacks = Array<(data:Float?) -> Void>()
        
        lastDataTime = NSDate.timeIntervalSinceReferenceDate()
        
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
    private func dataCallback(data:SensorData) {
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
        
        let touchDownTime = NSDate.timeIntervalSinceReferenceDate()
        
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
        
        let touchUpTime = NSDate.timeIntervalSinceReferenceDate()
        
        touchedDown = false
        currentRoll = 0.0
        currentPitch = 0.0
        
        let data = dataCache.getForTime(touchUpTime)
        data.touchUp()
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("touchEndCallback:"), userInfo: touchUpTime, repeats: false)
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
    @objc private func touchEndCallback(timer:NSTimer) {
        let touchUpTime = timer.userInfo as! NSTimeInterval
        let end = NSDate.timeIntervalSinceReferenceDate()
        
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
    private func calculateRoll(data:SensorData) -> Float {
        var totalRotation = currentRoll
        
        totalRotation += data.gyro.x * Float(NSTimeInterval(data.time - lastDataTime))
        
        return totalRotation
    }
    
    /// Internal function for calculation of pitch changes based upon new sensor data and time since last reading.
    /// - parameter Sensor: data to be analysed.
    /// - returns: New calcuation for pitch from touch down.
    private func calculatePitch(data:SensorData) -> Float {
        var totalPitch = currentPitch
        
        totalPitch += data.gyro.y * Float(NSTimeInterval(data.time - lastDataTime))
        
        return totalPitch
    }
    
    /// Internal function for calculation of instantaneous force based upon new sensor data and time since last reading.
    /// - parameter Sensor: data to be analysed.
    /// - returns: New calculation for instantaneous force.
    private func calculateForce(data:SensorData) -> Float {
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
    /// - parameter touchUpTime: Time touch up event occured.
    /// - parameter end: End time of window for analysis.
    /// - returns: New calculation of flick force.
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
    
    /// Internal function to fire during metric callbacks.
    private func fireDuringMetrics() {
        fireCallbacks(nil, callbacks: duringMetricsCallbacks)
    }
    
    /// Internal function to fire post metric callbacks.
    private func firePostMetrics() {
        fireCallbacks(nil, callbacks: postMetricsCallbacks)
    }
    
    /// Internal function to fire flick callbacks.
    /// - parameter data: Value representing flicked force.
    private func fireFlick(data:Float) {
       fireCallbacks(data, callbacks: flickCallbacks)
    }
    
    /// Internal function to fire no flick callbacks.
    /// - parameter data: Value representing flicked force.
    private func fireNoFlick(data:Float) {
        fireCallbacks(data, callbacks: noFlickCallBacks)
    }
    
    /// Internal function to fire hard press callbacks.
    /// - parameter data: Value representing touch force.
    private func fireHardPress(data:Float) {
        fireCallbacks(data, callbacks: hardPressCallbacks)
    }
    
    /// Internal function to fire medium press callbacks.
    /// - parameter data: Value representing touch force.
    private func fireMediumPress(data:Float) {
        fireCallbacks(data, callbacks: mediumPressCallbacks)
    }
    
    /// Internal function to fire soft press callbacks.
    /// - parameter data: Value representing touch force.
    private func fireSoftPress(data:Float) {
        fireCallbacks(data, callbacks: softPressCallbacks)
    }
    
    /// Internal function to fire all press callbacks.
    /// - parameter data: Value representing touch force.
    private func fireAllPress(data:Float) {
        fireCallbacks(data, callbacks: allPressCallbacks)
    }
    
    /// Internal function to fire a set of callbacks.
    /// - parameter data: Data to be passed to callbacks.
    /// - parameter callbacks: Set of callbacks to be fired.
    private func fireCallbacks(data:Float?, callbacks:[(data:Float?) -> Void]) {
        for cb in callbacks {
            cb(data: data)
        }
    }
    
    /// Event subscription system, subscribing to defined events causes callback to be fired when specified event occurs.
    /// - parameter event: Type of event to be subscribed.
    /// - parameter callback: Function with data parameter to be called on event occurence.
    func subscribe(event:EXTEvent, callback:(data:Float?) -> Void) {
        switch event {
        case .Metrics:
            metricsCallbacks.append(callback)
        case .DuringMetrics:
            duringMetricsCallbacks.append(callback)
        case .PostMetrics:
            postMetricsCallbacks.append(callback)
        case .Flick:
            flickCallbacks.append(callback)
        case .NoFlick:
            noFlickCallBacks.append(callback)
        case .HardPress:
            hardPressCallbacks.append(callback)
        case .MediumPress:
            mediumPressCallbacks.append(callback)
        case .SoftPress:
            softPressCallbacks.append(callback)
        case .AllPress:
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
    case Metrics, DuringMetrics, PostMetrics, Flick, NoFlick, HardPress, MediumPress, SoftPress, AllPress
}