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
    
    private var continousTimer:NSTimer!
    private var touchTimer:NSTimer!
    
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
        
        flickedCallbacks = Array<() -> Void>()
        hardPressCallbacks = Array<() -> Void>()
        mediumPressCallbacks = Array<() -> Void>()
        softPressCallbacks = Array<() -> Void>()
    }
    
    func startDetection() {
        continousTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("continousCallback:"), userInfo: nil, repeats: true)
    }
    
    func stopDetection() {
        continousTimer.invalidate()
    }
    
    @objc func continousCallback(timer:NSTimer) {
        currentForce = calculateForce()
        let data = dataCache.getForTime(NSDate.timeIntervalSinceReferenceDate())
        handModel.updateState(data)
    }
    
    func touchDown(touchDownTime:NSTimeInterval) {
        touchDown = true
        
        touchTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("touchCallback:"), userInfo: touchDownTime, repeats: true)
        
        let touchForce = calculateTouchForce(touchDownTime)
        let data = dataCache.getForTime(touchDownTime)
        data.touched()
        
        if (touchForce > hardForceThreshold) {
            fireHardPress()
            data.touchForce = "Hard"
        } else if (touchForce > medForceThreshold) {
            fireMediumPress()
            data.touchForce = "Medium"
        } else {
            fireSoftPress()
            data.touchForce = "Soft"
        }
    }
    
    func touchUp(touchUpTime:NSTimeInterval) {
        touchDown = false
        currentRotation = 0.0
        
        touchTimer.invalidate()
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("touchEndCallback:"), userInfo: touchUpTime, repeats: true)
    }
    
    func touchCancelled() {
        touchDown = false
    }
    
    @objc func touchCallback(timer:NSTimer) {
        let touchDownTime = timer.userInfo as! NSTimeInterval
        
        currentRotation = calculateRotation(touchDownTime)
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
    
    private func calculateRotation(touchDownTime:NSTimeInterval) -> Float {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        let data = dataCache.getRangeForTime(touchDownTime, end: currentTime)
        
        var totalRotation:Float = 0.0
        
        if (data.count > 1) {
            for i in 1..<data.count {
                totalRotation += data[i].gyro.x * Float(NSTimeInterval(data[i].time - data[i-1].time))
            }
        }
        
        return totalRotation
    }
    
    private func calculateForce() -> Float {
        let data = dataCache.getForTime(NSDate.timeIntervalSinceReferenceDate())
        
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
            let vectorLength = sqrt(pow(d.acc.x, 2) + pow(d.acc.y, 2) + pow(d.acc.z, 2))
            
            if (vectorLength > flickThreshold) {
                flicked = true
            }
        }
        
        return flicked
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
}

enum EventType {
    case Flicked, HardPress, MediumPress, SoftPress
}