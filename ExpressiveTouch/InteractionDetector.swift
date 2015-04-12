//
//  InteractionDetector.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class InteractionDetector {
    var currentForce:Float
    var currentRotation:Float
    var currentPitch:Float
    var touchDown:Bool
    
    private var lastDataTime:NSTimeInterval!
    
    private var metricsCallbacks:Array<(data:Float!) -> Void>
    private var flickedCallbacks:Array<(data:Float!) -> Void>
    private var hardPressCallbacks:Array<(data:Float!) -> Void>
    private var mediumPressCallbacks:Array<(data:Float!) -> Void>
    private var softPressCallbacks:Array<(data:Float!) -> Void>
    
    private let dataCache:WaxCache
    private let touchForceFilter:Float = 0.1
    private let medForceThreshold:Float = 5
    private let hardForceThreshold:Float = 15
    private let flickThreshold:Float = 0.0 // Set for evaluations
    
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
    
    func startDetection() {
        dataCache.subscribe(dataCallback)
    }
    
    private func dataCallback(data:WaxData) {
        currentForce = calculateForce(data)
        
        if (touchDown) {
            currentRotation = calculateRotation(data)
            currentPitch = calculatePitch(data)
        }
        
        lastDataTime = NSDate.timeIntervalSinceReferenceDate()
        fireMetrics()
    }
    
    func stopDetection() {
        dataCache.clearSubscriptions()
        clearSubscriptions()
    }
    
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
    
    func touchUp(touchUpTime:NSTimeInterval) {
        touchDown = false
        currentRotation = 0.0
        currentPitch = 0.0
        
        let data = dataCache.getForTime(touchUpTime)
        data.touchUp()
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("touchEndCallback:"), userInfo: touchUpTime, repeats: false)
    }
    
    func touchCancelled() {
        touchDown = false
    }
    
    @objc private func touchEndCallback(timer:NSTimer) {
        let touchUpTime = timer.userInfo as! NSTimeInterval
        let end = NSDate.timeIntervalSinceReferenceDate()
        
        let flickForce = detectFlick(touchUpTime, end: end)
        
        if (flickForce > flickThreshold) {
            fireFlicked(flickForce)
        }
    }
    
    private func calculateRotation(data:WaxData) -> Float {
        var totalRotation = currentRotation
        
        totalRotation += data.gyro.x * Float(NSTimeInterval(data.time - lastDataTime))
        
        return totalRotation
    }
    
    private func calculatePitch(data:WaxData) -> Float {
        var totalPitch = currentPitch
        
        totalPitch += data.gyro.y * Float(NSTimeInterval(data.time - lastDataTime))
        
        return totalPitch
    }
    
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
    
    private func detectFlick(touchUpTime:NSTimeInterval, end:NSTimeInterval) -> Float {
        let data = dataCache.getRangeForTime(touchUpTime, end: end)
        
        var maxMag:Float = 0.0
        
        for d in data {
            if (d.getAccNoGrav().magnitude() > maxMag) {
                maxMag = d.getAccNoGrav().magnitude()
            }
        }
        
        return maxMag
    }
    
    private func fireMetrics() {
        fireCallbacks(nil, callbacks: metricsCallbacks)
    }
    
    private func fireFlicked(data:Float) {
       fireCallbacks(data, callbacks: flickedCallbacks)
    }
    
    private func fireHardPress(data:Float) {
        fireCallbacks(data, callbacks: hardPressCallbacks)
    }
    
    private func fireMediumPress(data:Float) {
        fireCallbacks(data, callbacks: mediumPressCallbacks)
    }
    
    private func fireSoftPress(data:Float) {
        fireCallbacks(data, callbacks: softPressCallbacks)
    }
    
    private func fireCallbacks(data:Float!, callbacks:[(data:Float!) -> Void]) {
        for cb in callbacks {
            cb(data: data)
        }
    }
    
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
    
    func clearSubscriptions() {
        metricsCallbacks.removeAll(keepCapacity: false)
        flickedCallbacks.removeAll(keepCapacity: false)
        hardPressCallbacks.removeAll(keepCapacity: false)
        mediumPressCallbacks.removeAll(keepCapacity: false)
        softPressCallbacks.removeAll(keepCapacity: false)
    }
}

enum EventType {
    case Metrics, Flicked, HardPress, MediumPress, SoftPress
}