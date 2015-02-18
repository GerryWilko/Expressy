//
//  InteractionView.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 18/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class InteractionView: UIView {
    var delegate:ETDetectorViewController!
    var touchDown:Bool
    var start:Int
    
    required init(coder aDecoder: NSCoder) {
        touchDown = false
        start = 0
        
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        touchDown = true
        
        let processor = WaxProcessor.getProcessor()
        start = processor.gyroCache.get(UInt(processor.gyroCache.count() - 1)).time
        
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (touchDown) {
            touchDown = false
            
            let processor = WaxProcessor.getProcessor()
            let rotation = calculateRotation(start, end: processor.gyroCache.get(UInt(processor.gyroCache.count() - 1)).time)
            
            let tapAlert = UIAlertController(title: "Rotated", message: String(format:"%f", rotation), preferredStyle: UIAlertControllerStyle.Alert)
            tapAlert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
            delegate.presentViewController(tapAlert, animated: true, completion: nil)
        }
        
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        touchDown = false
        
        super.touchesCancelled(touches, withEvent: event)
    }
    
    func calculateRotation(start:Int, end:Int) -> Double {
        let processor = WaxProcessor.getProcessor()
        
        let data = processor.gyroCache.getRangeForTime(start, end: end)
        
        var totalRotation = 0.0
        
        for d in data[1..<data.count] {
            totalRotation += d.x * Double(NSTimeInterval(d.time - data[0].time))
        }
        
        return totalRotation
    }
}