//
//  InteractionDetectorVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 03/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit

class InteractionDetectorVC: UIViewController {
    fileprivate let detector:EXTInteractionDetector
    
    @IBOutlet weak var forceLbl: UILabel!
    @IBOutlet weak var rotationLbl: UILabel!
    @IBOutlet weak var pitchLbl: UILabel!
    @IBOutlet weak var flickedSwitch: UISwitch!
    
    required init?(coder aDecoder: NSCoder) {
        detector = EXTInteractionDetector(dataCache: SensorProcessor.dataCache)
        super.init(coder: aDecoder)
        detector.subscribe(.metrics, callback: dataCallback)
        detector.subscribe(.flick, callback: flickedCallback)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        detector.startDetection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        detector.stopDetection()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        detector.touchDown()
        flickedSwitch.setOn(false, animated: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        detector.touchUp()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        detector.touchCancelled()
    }
    
    fileprivate func dataCallback(_ data:Float?) {
        forceLbl.text = String(format: "%.2f", detector.currentForce)
        rotationLbl.text = String(format: "%.2f", detector.currentRoll)
        pitchLbl.text = String(format: "%.2f", detector.currentPitch)
    }
    
    fileprivate func flickedCallback(_ data:Float?) {
        self.flickedSwitch.setOn(true, animated: true)
    }
}
