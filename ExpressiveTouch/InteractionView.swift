//
//  InteractionView.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 18/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class InteractionView: UIView {
    var timer:NSTimer!
    
    let detector:InteractionDetector
    
    @IBOutlet weak var rotationLbl: UILabel!
    @IBOutlet weak var forceLbl: UILabel!
    
    @IBOutlet weak var pOrientationLbl: UILabel!
    @IBOutlet weak var pForceLbl: UILabel!
    @IBOutlet weak var flickedSwitch: UISwitch!
    
    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector()
        
        super.init(coder: aDecoder)
        
        detector.subscribe(EventType.Flicked, callback: {
            self.flickedSwitch.setOn(true, animated: true)
        })
        
        detector.subscribe(EventType.PadPress, callback: {
            self.pOrientationLbl.text = "Pad Press"
        })
        
        detector.subscribe(EventType.KnucklePress, callback: {
            self.pOrientationLbl.text = "Knuckle Press"
        })
        
        detector.subscribe(EventType.SidePress, callback: {
            self.pOrientationLbl.text = "Side Press"
        })
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!detector.touchDown) {
            detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
            forceLbl.text = String(format: "%.2f", detector.currentForce)
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("interactionCallback:"), userInfo: nil, repeats: true)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (detector.touchDown) {
            detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
            timer.invalidate()
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        detector.touchCancelled()
    }
    
    func interactionCallback(timer:NSTimer) {
        rotationLbl.text = String(format: "%.2f", detector.currentRotation)
    }
}