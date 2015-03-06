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
    var position:Vector3D
    
    let initialPos = Vector3D(x: 0, y: 0, z: 1)
    let flickThreshold:Float = 1.5
    
    @IBOutlet weak var rotationLbl: UILabel!
    @IBOutlet weak var forceLbl: UILabel!
    @IBOutlet weak var pitchLbl: UILabel!
    @IBOutlet weak var flickedSwitch: UISwitch!
    
    @IBOutlet weak var posXLbl: UILabel!
    @IBOutlet weak var posYLbl: UILabel!
    @IBOutlet weak var posZLbl: UILabel!
    @IBOutlet weak var madgXLbl: UILabel!
    @IBOutlet weak var madgYLbl: UILabel!
    @IBOutlet weak var madgZLbl: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        touchDown = false
        position = Vector3D(x: 0, y: 0, z: 1)
        
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!touchDown) {
            touchDown = true
            let touchDownTime = NSDate.timeIntervalSinceReferenceDate()
            
            forceLbl.text = String(format: "%.2f", calculateForce(touchDownTime))
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("interactionCallback:"), userInfo: touchDownTime, repeats: true)
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
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        calculatePosition(touchDownTime, currentTime: currentTime)
        rotationLbl.text = String(format: "%.2f", calculateRotation(touchDownTime, currentTime: currentTime))
        pitchLbl.text = detectPitch()
    }
    
    func calculateRotation(touchDownTime:NSTimeInterval, currentTime:NSTimeInterval) -> Float {
        let processor = WaxProcessor.getProcessor()
        
        let data = processor.gyroCache.getRangeForTime(touchDownTime, end: currentTime)
        
        var totalRotation:Float = 0.0
        
        if (data.count > 1) {
            for i in 1..<data.count {
                totalRotation += data[i].x * Float(NSTimeInterval(data[i].time - data[i-1].time))
            }
        }
        
        return totalRotation
    }
    
    func detectPitch() -> String {
        return position.y > 0 ? "Flat" : "Upright"
    }
    
    func calculatePosition(touchDownTime:NSTimeInterval, currentTime:NSTimeInterval) {
        let processor = WaxProcessor.getProcessor()
        
        let info = processor.infoCache.getForTime(currentTime)
        
        madgXLbl.text = String(stringInterpolationSegment: info.madgwick.x)
        madgYLbl.text = String(stringInterpolationSegment: info.madgwick.y)
        madgZLbl.text = String(stringInterpolationSegment: info.madgwick.z)
        
        position = initialPos * info.madgwick
        
        posXLbl.text = String(stringInterpolationSegment: position.x)
        posYLbl.text = String(stringInterpolationSegment: position.y)
        posZLbl.text = String(stringInterpolationSegment: position.z)
        
        println("Madgwick(x: \(info.madgwick.x), y: \(info.madgwick.y), z: \(info.madgwick.z), w: \(info.madgwick.w))")
        println("Position(x: \(position.x), y: \(position.y), z: \(position.z))")
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
    
    func calculateForce(touchDownTime:NSTimeInterval) -> Float {
        let processor = WaxProcessor.getProcessor()
        
        let data = processor.accCache.getRangeForTime(touchDownTime - 1, end: touchDownTime)
        
        var force:Float = 0.0
        
        for d in data {
            force += sqrt(pow(d.x, 2) + pow(d.y, 2) + pow(d.z, 2))
        }
        
        return force
    }
}