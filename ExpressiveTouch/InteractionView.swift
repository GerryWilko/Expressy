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
    
    @IBOutlet weak var forceLbl: UILabel!
    @IBOutlet weak var rotationLbl: UILabel!
    @IBOutlet weak var pitchLbl: UILabel!
    @IBOutlet weak var rollLbl: UILabel!
    @IBOutlet weak var yawLbl: UILabel!
    @IBOutlet weak var flickedSwitch: UISwitch!
    
    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        detector.startDetection()
        
        super.init(coder: aDecoder)
        
        detector.subscribe(.Metrics, callback: dataCallback)
        
        detector.subscribe(EventType.Flicked, callback: {
            self.flickedSwitch.setOn(true, animated: true)
        })
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!detector.touchDown) {
            detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
            flickedSwitch.setOn(false, animated: true)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (detector.touchDown) {
            detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
        }
    }
    
    func dataCallback() {
        forceLbl.text = String(format: "%.2f", detector.currentForce)
        rotationLbl.text = String(format: "%.2f", detector.currentRotation)
        pitchLbl.text = String(format: "%.2f", detector.handModel.getPitch())
        rollLbl.text = String(format: "%.2f", detector.handModel.getRoll())
    }
}