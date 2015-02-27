//
//  InteractionView.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 18/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class InteractionView: UIView {
    var touchDown:Bool
    var delegate:UIViewController!
    var timer:NSTimer!
    
    let flickThreshold = 1.5
    
    @IBOutlet weak var rotationLbl: UILabel!
    @IBOutlet weak var forceLbl: UILabel!
    @IBOutlet weak var flickedSwitch: UISwitch!
    
    required init(coder aDecoder: NSCoder) {
        touchDown = false
        
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!touchDown) {
            touchDown = true
            let touchDownTime = NSDate.timeIntervalSinceReferenceDate()
            
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("interactionCallback:"), userInfo: touchDownTime, repeats: true)
            
            forceLbl.text = String(format: "%.2f", calculateForce(touchDownTime))
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (touchDown) {
            touchDown = false
            let touchDownTime = timer.userInfo as! NSTimeInterval
            let touchUpTime = NSDate.timeIntervalSinceReferenceDate()
            
            detectFlick(touchDownTime, touchUpTime: touchUpTime)
            
            timer.invalidate()
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        touchDown = false
        timer.invalidate()
    }
    
    func interactionCallback(timer:NSTimer) {
        let touchDownTime = timer.userInfo as! NSTimeInterval
        rotationLbl.text = String(format: "%.2f", calculateRotation(touchDownTime, touchUpTime: NSDate.timeIntervalSinceReferenceDate()))
    }
    
    func calculateRotation(touchDownTime:NSTimeInterval, touchUpTime:NSTimeInterval) -> Double {
        let processor = WaxProcessor.getProcessor()
        
        let data = processor.gyroCache.getRangeForTime(touchDownTime, end: touchUpTime)
        
        var totalRotation = 0.0
        
        if (data.count > 1) {
            for i in 1..<data.count {
                totalRotation += data[i].x * Double(NSTimeInterval(data[i].time - data[i-1].time))
            }
        }
        
        return totalRotation
    }
    
    func detectFlick(touchDownTime:NSTimeInterval, touchUpTime:NSTimeInterval) {
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("flickCallback:"), userInfo: [touchDownTime, touchUpTime], repeats: false)
    }
    
    func flickCallback(timer:NSTimer) {
        let touchTimes = timer.userInfo as! [NSTimeInterval]
        let processor = WaxProcessor.getProcessor()
        
        let data = processor.accCache.getRangeForTime(touchTimes[1], end: NSDate.timeIntervalSinceReferenceDate())
        
        var flicked = false
        
        for d in data {
            let vectorLength = sqrt(pow(d.x, 2) + pow(d.y, 2) + pow(d.z, 2))
            
            if (vectorLength > flickThreshold) {
                flicked = true
            }
        }
        
        flickedSwitch.setOn(flicked, animated: true)
    }
    
    func calculateForce(touchDownTime:NSTimeInterval) -> Double {
        let processor = WaxProcessor.getProcessor()
        
        let data = processor.accCache.getRangeForTime(touchDownTime - 1, end: touchDownTime)
        
        var force = 0.0
        
        for d in data {
            force += sqrt(pow(d.x, 2) + pow(d.y, 2) + pow(d.z, 2))
        }
        
        return force
    }
}