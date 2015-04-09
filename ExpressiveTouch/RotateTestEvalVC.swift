//
//  RotateTestEvalVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 08/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class RotateTestEvalVC: UIViewController {
    private var stage:Int
    private var maxValue:Float
    private var minValue:Float
    private var evalCount:Int
    private var angleDifference:Float!
    private var lastTransform:CGAffineTransform!
    
    private let detector:InteractionDetector
    private let csvBuilder:CSVBuilder
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var placeholderImage: UIImageView!
    @IBOutlet weak var rotateImage: UIImageView!
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var progressWheel: UIActivityIndicatorView!
    
    required init(coder aDecoder: NSCoder) {
        stage = 1
        maxValue = 0.0
        minValue = 0.0
        evalCount = 0
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        detector.startDetection()
        csvBuilder = CSVBuilder(fileNames: ["rotate.csv", "rotateData.csv"], headerLines: ["Time,Max Angle,Min Angle,Placeholder Angle,Image Angle,End Image Angle", WaxData.headerLine()])
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
        
        switch (stage) {
        case 1:
            detector.subscribe(EventType.Metrics, callback: {
                if (self.maxValue < self.detector.currentRotation) {
                    self.maxValue = self.detector.currentRotation
                }
                
                if (self.minValue > self.detector.currentRotation) {
                    self.minValue = self.detector.currentRotation
                }
            })
            instructionLbl.text = "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down."
            progressWheel.startAnimating()
            break
        case 2:
            let touch = touches.first as! UITouch
            
            if (touch.view == rotateImage) {
                detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
                detector.subscribe(EventType.Metrics, callback: {
                    self.rotateImage.transform = CGAffineTransformRotate(self.lastTransform, CGFloat(self.detector.currentRotation) * CGFloat(M_PI / 180))
                })
            }
            break
        default:
            break
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
        
        switch (stage) {
        case 1:
            detector.clearSubscriptions()
            instructionLbl.text = "Press next to advance to the next stage or try again."
            progressWheel.stopAnimating()
            self.view.userInteractionEnabled = false
            break
        case 2:
            detector.clearSubscriptions()
            
            let touch = touches.first as! UITouch
            
            if (touch.view == rotateImage) {
                let placeholderDegrees = atan2f(Float(placeholderImage.transform.b), Float(placeholderImage.transform.a)) * Float(180 / M_PI)
                let imageDegrees = atan2f(Float(rotateImage.transform.b), Float(rotateImage.transform.a)) * Float(180 / M_PI)
                rotateImage.userInteractionEnabled = false
                evalCount++
                
                progressBar.setProgress(Float(evalCount) / 10.0, animated: true)
            }
            break
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        self.performSegueWithIdentifier("rotateTestInstructions", sender: self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        detector.stopDetection()
    }
    
    func randomiseImages() {
        let range = UInt32(maxValue - minValue)
        let placeholderAngle = Float(Int(arc4random_uniform(range))) + minValue
        let rotateAngle = Float(Int(arc4random_uniform(range))) + minValue
        placeholderImage.transform = CGAffineTransformMakeRotation(CGFloat(MathUtils.deg2rad(placeholderAngle)))
        rotateImage.transform = CGAffineTransformMakeRotation(CGFloat(MathUtils.deg2rad(rotateAngle)))
        angleDifference = placeholderAngle - rotateAngle
        lastTransform = rotateImage.transform
    }
    
    @IBAction func next(sender: AnyObject) {
        switch (stage) {
        case 1:
            instructionLbl.hidden = true
            placeholderImage.hidden = false
            rotateImage.hidden = false
            
            randomiseImages()
            self.view.userInteractionEnabled = true
            stage++
            break
        case 2:
            if (evalCount < 10) {
                progressBar.setProgress(Float(evalCount) / 10.0, animated: true)
                randomiseImages()
                rotateImage.userInteractionEnabled = true
            } else {
                instructionLbl.hidden = false
                placeholderImage.hidden = true
                rotateImage.hidden = true
                
                instructionLbl.text = "Evaluation Complete. Thank you."
                stage++
            }
            break
        default:
            break
        }
    }
}