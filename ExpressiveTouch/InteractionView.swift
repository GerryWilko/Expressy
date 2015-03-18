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
    
    @IBOutlet weak var pPitchLbl: UILabel!
    @IBOutlet weak var pRollLbl: UILabel!
    @IBOutlet weak var flickedSwitch: UISwitch!
    
    @IBOutlet weak var gravXLbl: UILabel!
    @IBOutlet weak var gravYLbl: UILabel!
    @IBOutlet weak var gravZLbl: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        detector.startDetection()
        
        super.init(coder: aDecoder)
        
        detector.subscribe(EventType.Flicked, callback: {
            self.flickedSwitch.setOn(true, animated: true)
        })
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!detector.touchDown) {
            detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
            flickedSwitch.setOn(false, animated: true)
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("interactionCallback:"), userInfo: nil, repeats: true)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (detector.touchDown) {
            detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
            timer.invalidate()
        }
    }
    
    func interactionCallback(timer:NSTimer) {
        forceLbl.text = String(format: "%.2f", detector.currentForce)
        rotationLbl.text = String(format: "%.2f", detector.currentRotation)
        pPitchLbl.text = String(format: "%.2f", detector.handModel.getPitch())
        pRollLbl.text = String(format: "%.2f", detector.handModel.getRoll())
        
        let data = WaxProcessor.getProcessor().dataCache.getForTime(NSDate.timeIntervalSinceReferenceDate())
        
        gravXLbl.text = String(format: "%.2f", data.grav.x)
        gravYLbl.text = String(format: "%.2f", data.grav.y)
        gravZLbl.text = String(format: "%.2f", data.grav.z)
    }
}