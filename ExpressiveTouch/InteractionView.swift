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
    
    required init(coder aDecoder: NSCoder) {
        touchDown = false
        
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!touchDown) {
            let processor = WaxProcessor.getProcessor()
            touchDown = true
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("interactionCallback:"), userInfo: NSDate.timeIntervalSinceReferenceDate(), repeats: true)
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
        
        if (data.count > 1) {
            for i in 1..<data.count {
                let x = data[i].x
                let y = data[i].y
                let z = data[i].z
                
                let vectorLength = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
                
                if (vectorLength > flickThreshold) {
                    flicked = true
                }
            }
        }
        
        let message = flicked ? "Flicked!" : "No Flick"
        
        let flickAlert = UIAlertController(title: "Flicked", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        flickAlert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
        delegate.presentViewController(flickAlert, animated: true, completion: nil)
    }
}