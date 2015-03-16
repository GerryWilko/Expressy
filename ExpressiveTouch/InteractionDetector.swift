//
//  InteractionDetector.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class InteractionDetector {
    var touchDown:Bool
    var handModel:HandModel
    var currentForce:Float
    var currentRotation:Float
    
    private var timer:NSTimer!
    private var touchDownTime:NSTimeInterval!
    private var touchUpTime:NSTimeInterval!
    
    private var flickedCallbacks:Array<() -> Void>
    private var hardPressCallbacks:Array<() -> Void>
    private var softPressCallbacks:Array<() -> Void>
    
    private let forceThreshold:Float = 1.5
    private let flickThreshold:Float = 1.5
    
    init() {
        touchDown = false
        var data = WaxProcessor.getProcessor().dataCache.getForTime(NSDate.timeIntervalSinceReferenceDate())
        handModel = HandModel(data: data)
        currentForce = 0.0
        currentRotation = 0.0
        
        flickedCallbacks = Array<() -> Void>()
        hardPressCallbacks = Array<() -> Void>()
        softPressCallbacks = Array<() -> Void>()
    }
    
    func startDetection() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("detectionCallback:"), userInfo: nil, repeats: true)
    }
    
    func stopDetection() {
        timer.invalidate()
    }
    
    @objc func detectionCallback(timer:NSTimer) {
        let processor = WaxProcessor.getProcessor()
        
        currentForce = calculateForce()
        let data = processor.dataCache.getForTime(NSDate.timeIntervalSinceReferenceDate())
        handModel.updateState(data)
        
        if (touchDown) {
            currentRotation = calculateRotation()
        }
    }
    
    func touchDown(touchDownTime:NSTimeInterval) {
        touchDown = true
        self.touchDownTime = touchDownTime
        
        if (currentForce > forceThreshold) {
            fireHardPress()
        } else {
            fireSoftPress()
        }
    }
    
    func touchUp(touchUpTime:NSTimeInterval) {
        touchDown = false
        self.touchUpTime = touchUpTime
        currentRotation = 0.0
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("touchEndCallback:"), userInfo: [touchDownTime, touchUpTime], repeats: true)
    }
    
    func touchCancelled() {
        touchDown = false
    }
    
    @objc func touchEndCallback(timer:NSTimer) {
        let touchTimes = timer.userInfo as! [NSTimeInterval]
        let end = NSDate.timeIntervalSinceReferenceDate()
        
        let flicked = detectFlick(touchTimes[1], end: end)
        
        if (flicked) {
            fireFlicked()
        }
        
        if (NSDate.timeIntervalSinceReferenceDate() - touchTimes[1] > 1) {
            timer.invalidate()
        }
    }
    
    private func calculateRotation() -> Float {
        let processor = WaxProcessor.getProcessor()
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        let data = processor.dataCache.getRangeForTime(touchDownTime, end: currentTime)
        
        var totalRotation:Float = 0.0
        
        if (data.count > 1) {
            for i in 1..<data.count {
                totalRotation += data[i].gyro.x * Float(NSTimeInterval(data[i].time - data[i-1].time))
            }
        }
        
        return totalRotation
    }
    
    private func calculateForce() -> Float {
        let processor = WaxProcessor.getProcessor()
        
        let data = processor.dataCache.getForTime(NSDate.timeIntervalSinceReferenceDate())
        let accNoGrav = data.getAccNoGrav()
        let force = (fabs(accNoGrav.x) + fabs(accNoGrav.y) + fabs(accNoGrav.z))
        
        return force
    }
    
    private func detectFlick(touchUpTime:NSTimeInterval, end:NSTimeInterval) -> Bool {
        let processor = WaxProcessor.getProcessor()
        
        let data = processor.dataCache.getRangeForTime(touchUpTime, end: end)
        
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
    case Flicked, HardPress, SoftPress
}