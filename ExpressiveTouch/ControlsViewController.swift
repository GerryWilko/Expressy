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
    
    private var touchDownValue:Float!
    
    @IBOutlet weak var barLbl1: UILabel!
    @IBOutlet weak var barLbl2: UILabel!
    @IBOutlet weak var progressBar1: UIProgressView!
    
    @IBOutlet var knobPlaceholder: UIView!
    @IBOutlet var valueLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        detector.startDetection()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let knob = Knob(frame: knobPlaceholder.bounds)
        knob.addTarget(self, action: "knobValueChanged:", forControlEvents: .ValueChanged)
        knobPlaceholder.addSubview(knob)
    }
    
    @IBAction func bar1TouchDown(sender: UIButton) {
        detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
        touchDownValue = progressBar1.progress * 100
        detector.subscribe(EventType.Metrics, callback: {
            var newValue = self.touchDownValue + self.detector.currentRotation
            
            if (newValue > 100) {
                newValue = 100.0
            } else if (newValue < 0) {
                newValue = 0
            }
            
            self.progressBar1.progress = newValue / 100
            self.barLbl1.text = String(format: "%.2f", newValue)
        })
    }
    
    @IBAction func bar1TouchUp(sender: UIButton) {
        detector.clearSubscriptions()
        detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
    }
    
    @IBAction func progBar2Changed(sender: UISlider) {
        barLbl2.text = String(format: "%.2f", sender.value)
    }
    
    func knobValueChanged(knob: Knob) {
        valueLabel.text = String(format: "%.2f", knob.value)
    }
}