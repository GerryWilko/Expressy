//
//  ControlsViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 22/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class ControlsViewController: UIViewController {
    let detector:InteractionDetector
    
    @IBOutlet weak var barLbl1: UILabel!
    @IBOutlet weak var barLbl2: UILabel!
    @IBOutlet weak var progressBar1: UIProgressView!
    
    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        detector.startDetection()
        super.init(coder: aDecoder)
    }
    
    @IBAction func bar1TouchDown(sender: UIButton) {
        detector.subscribe(EventType.Metrics, callback: {
            let newValue = self.progressBar1.progress + self.detector.currentRotation
            self.progressBar1.progress = newValue
            self.barLbl1.text = String(format: "%.2f", newValue)
        })
    }
    
    @IBAction func bar1TouchUp(sender: UIButton) {
        detector.clearSubscriptions()
    }
    
    @IBAction func progBar2Changed(sender: UISlider) {
        barLbl2.text = String(format: "%.2f", sender.value)
    }
}