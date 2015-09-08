//
//  InteractionDetectorVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 03/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class InteractionDetectorVC: UIViewController {
    private let detector:InteractionDetector
    
    @IBOutlet weak var forceLbl: UILabel!
    @IBOutlet weak var rotationLbl: UILabel!
    @IBOutlet weak var pitchLbl: UILabel!
    @IBOutlet weak var flickedSwitch: UISwitch!
    
    required init?(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: SensorProcessor.dataCache)
        super.init(coder: aDecoder)
        detector.subscribe(EventType.Metrics, callback: dataCallback)
        detector.subscribe(EventType.Flick, callback: flickedCallback)
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
        rotationLbl.text = String(format: "%.2f", detector.currentRotation)
        pitchLbl.text = String(format: "%.2f", detector.currentPitch)
    }
    
    private func flickedCallback(data:Float?) {
        self.flickedSwitch.setOn(true, animated: true)
    }
}