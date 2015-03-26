//
//  ControlsDemoVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 22/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class ControlsDemoVC: UIViewController {
    let detector:InteractionDetector
    
    private var startTransform:CGAffineTransform!
    
    @IBOutlet weak var barLbl1: UILabel!
    @IBOutlet weak var barLbl2: UILabel!
    @IBOutlet weak var progressBar1: UIProgressView!
    
    @IBOutlet weak var imageETSwitch: UISwitch!
    @IBOutlet weak var imageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        detector.startDetection()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTransform = imageView.transform
        imageView.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: Selector("imageRotated:")))
    }
    
    @IBAction func bar1TouchDown(sender: UIButton) {
        detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
        let touchDownValue = progressBar1.progress * 100
        detector.subscribe(EventType.Metrics, callback: {
            var newValue = touchDownValue + self.detector.currentRotation
            
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
        detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
        detector.clearSubscriptions()
    }
    
    @IBAction func progBar2Changed(sender: UISlider) {
        barLbl2.text = String(format: "%.2f", sender.value)
    }
    
    func imageRotated(gesture:UIRotationGestureRecognizer) {
        if (!imageETSwitch.on) {
            imageView.transform = CGAffineTransformRotate(startTransform, gesture.rotation)
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        
        if (imageETSwitch.on && touch.view == imageView)
        {
            detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
            detector.subscribe(EventType.Metrics, callback: {
                self.imageView.transform = CGAffineTransformRotate(self.startTransform, CGFloat(self.detector.currentRotation) * CGFloat(M_PI / 180))
            })
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        
        if (imageETSwitch.on && touch.view == imageView)
        {
            detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
            detector.clearSubscriptions()
        }
        
        startTransform = imageView.transform
    }
    
    @IBAction func resetModel(sender: UIBarButtonItem) {
        MadgwickAHRSreset()
    }
}