//
//  InteractionDetector.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class InteractionDetector {
    var handModel:HandModel
    var currentForce:Float
    var currentRotation:Float
    var touchDown:Bool
    
    private var lastDataTime:NSTimeInterval!
    
    private var metricsCallbacks:Array<() -> Void>
    private var flickedCallbacks:Array<() -> Void>
    private var hardPressCallbacks:Array<() -> Void>
    private var mediumPressCallbacks:Array<() -> Void>
    private var softPressCallbacks:Array<() -> Void>
    
    private let dataCache:WaxCache
    private let medForceThreshold:Float = 1.5
    private let hardForceThreshold:Float = 3.0
    private let flickThreshold:Float = 1.5
    
    init(dataCache:WaxCache) {
        self.dataCache = dataCache
        
        var data = dataCache.getForTime(NSDate.timeIntervalSinceReferenceDate())
        handModel = HandModel(data: data)
        currentForce = 0.0
        currentRotation = 0.0
        touchDown = false
        
        metricsCallbacks = Array<() -> Void>()
        
        flickedCallbacks = Array<() -> Void>()
        hardPressCallbacks = Array<() -> Void>()
        mediumPressCallbacks = Array<() -> Void>()
        softPressCallbacks = Array<() -> Void>()
    }
    
    func startDetection() {
        dataCache.subscribe(dataCallback)
    }
    
    func dataCallback(data:WaxData) {
        currentForce = calculateForce(data)
        handModel.updateState(data)
        
        if (touchDown) {
            currentRotation = calculateRotation(data)
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
        data.touched(touchForce)
        
        if (touchForce > hardForceThreshold) {
            fireHardPress()
        } else if (touchForce > medForceThreshold) {
            fireMediumPress()
        } else {
            fireSoftPress()
        }
    }
    
    func touchUp(touchUpTime:NSTimeInterval) {
        touchDown = false
        currentRotation = 0.0
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("touchEndCallback:"), userInfo: touchUpTime, repeats: true)
    }
    
    func touchCancelled() {
        touchDown = false
    }
    
    @objc func touchEndCallback(timer:NSTimer) {
        let touchUpTime = timer.userInfo as! NSTimeInterval
        let end = NSDate.timeIntervalSinceReferenceDate()
        
        let flicked = detectFlick(touchUpTime, end: end)
        
        if (flicked) {
            fireFlicked()
        }
        
        if (NSDate.timeIntervalSinceReferenceDate() - touchUpTime > 1) {
            timer.invalidate()
        }
    }
    
    private func calculateRotation(data:WaxData) -> Float {
        var totalRotation:Float = currentRotation
        
        totalRotation += data.gyro.x * Float(NSTimeInterval(data.time - lastDataTime))
        
        return totalRotation
    }
    
    private func calculateForce(data:WaxData) -> Float {
        return data.getAccNoGrav().magnitude()
    }
    
    private func calculateTouchForce(touchDownTime:NSTimeInterval) -> Float {
        let data = dataCache.getRangeForTime(touchDownTime - 1, end: touchDownTime)
        
        var force:Float = 0.0
        
        
        for d in data {
            force += d.getAccNoGrav().magnitude()
        }
        
        return force
    }
    
    private func detectFlick(touchUpTime:NSTimeInterval, end:NSTimeInterval) -> Bool {
        let data = dataCache.getRangeForTime(touchUpTime, end: end)
        
        var flicked = false
        
        for d in data {
            if (d.acc.magnitude() > flickThreshold) {
                flicked = true
            }
        }
        
        return flicked
    }
    
    private func fireMetrics() {
        fireCallbacks(metricsCallbacks)
    }
    
    private func fireFlicked() {
       fireCallbacks(flickedCallbacks)
    }
    
    private func fireHardPress() {
        fireCallbacks(hardPressCallbacks)
    }
    
    private func fireMediumPress() {
        fireCallbacks(mediumPressCallbacks)
    }
    
    private func fireSoftPress() {
        fireCallbacks(softPressCallbacks)
    }
    
    private func fireCallbacks(callbacks:[() -> Void]) {
        for cb in callbacks {
            cb()
        }
    }
    
    func subscribe(event:EventType, callback:() -> Void) {
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