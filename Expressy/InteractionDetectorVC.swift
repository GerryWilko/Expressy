//
//  InteractionDetectorVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 03/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class InteractionDetectorVC: UIViewController {
    private let detector:EXTInteractionDetector
    
    @IBOutlet weak var forceLbl: UILabel!
    @IBOutlet weak var rotationLbl: UILabel!
    @IBOutlet weak var pitchLbl: UILabel!
    @IBOutlet weak var flickedSwitch: UISwitch!
    
    required init?(coder aDecoder: NSCoder) {
        detector = EXTInteractionDetector(dataCache: SensorProcessor.dataCache)
        super.init(coder: aDecoder)
        detector.subscribe(.Metrics, callback: dataCallback)
        detector.subscribe(.Flick, callback: flickedCallback)
    }
    
    override func viewWillAppear(animated: Bool) {
        detector.startDetection()
    }
    
    override func viewWillDisappear(animated: Bool) {
        detector.stopDetection()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        detector.touchDown()
        flickedSwitch.setOn(false, animated: true)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        detector.touchUp()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        detector.touchCancelled()
    }
    
    private func dataCallback(data:Float?) {
        forceLbl.text = String(format: "%.2f", detector.currentForce)
        rotationLbl.text = String(format: "%.2f", detector.currentRoll)
        pitchLbl.text = String(format: "%.2f", detector.currentPitch)
    }
    
    private func flickedCallback(data:Float?) {
        self.flickedSwitch.setOn(true, animated: true)
    }
}