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
    
    private var padPressCallbacks:Array<() -> Void>
    private var sidePressCallbacks:Array<() -> Void>
    private var knucklePressCallbacks:Array<() -> Void>
    private var flickedCallbacks:Array<() -> Void>
    private var hardPressCallbacks:Array<() -> Void>
    private var softPressCallbacks:Array<() -> Void>
    
    private let forceThreshold:Float = 1.5
    private let flickThreshold:Float = 1.5
    
    init() {
        touchDown = false
        var data = WaxProcessor.getProcessor().dataCache.getForTime(NSDate.timeIntervalSinceReferenceDate())
        handModel = HandModel(data: data)
        currentForce = 1.0
        currentRotation = 0.0
        
        padPressCallbacks = Array<() -> Void>()
        sidePressCallbacks = Array<() -> Void>()
        knucklePressCallbacks = Array<() -> Void>()
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
    
    func detectionCallback(timer:NSTimer!) {
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
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("touchEndCallback"), userInfo: [touchDownTime, touchUpTime], repeats: false)
    }
    
    func touchCancelled() {
        touchDown = false
    }
    
    func touchEndCallback() {
        //let touchTimes = timer.userInfo as! [NSTimeInterval]
        let end = NSDate.timeIntervalSinceReferenceDate()
        
        let flicked = detectFlick(touchUpTime, end: end)
        
        if (flicked) {
            fireFlicked()
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
        let force = currentForce * (accNoGrav.x + accNoGrav.y + accNoGrav.z)
        
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
    
    private func firePadPress() {
        fireCallbacks(padPressCallbacks)
    }
    
    private func fireSidePress() {
        fireCallbacks(sidePressCallbacks)
    }
    
    private func fireKnucklePress() {
        fireCallbacks(knucklePressCallbacks)
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
        case .PadPress:
            padPressCallbacks.append(callback)
            break
        case .SidePress:
            sidePressCallbacks.append(callback)
            break
        case .KnucklePress:
            knucklePressCallbacks.append(callback)
            break
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
    case PadPress, SidePress, KnucklePress, Flicked, HardPress, SoftPress
}