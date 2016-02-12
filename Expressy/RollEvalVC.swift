//
//  RollEvalVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 08/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class RollEvalVC: EvaluationVC {
    private var stage:Int
    private var maxValue:Float
    private var minValue:Float
    private var evalCount:Int
    private var angleDifference:Float!
    private var lastTransform:CGAffineTransform!
    private var touchTime:NSTimeInterval!
    
    private let minAngle:Float = 5.0
    
    @IBOutlet weak var placeholderImage: UIImageView!
    @IBOutlet weak var rotateImage: UIImageView!
    @IBOutlet weak var leftBar: UIProgressView!
    @IBOutlet weak var rightBar: UIProgressView!
    
    required init?(coder aDecoder: NSCoder) {
        stage = 1
        maxValue = 0.0
        minValue = 0.0
        evalCount = 0
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCSV("roll", headerLine: "Participant ID,Time,Max Angle,Min Angle,Placeholder Angle,Angle to Rotate,End Image Angle,Time Taken")
        leftBar.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        self.performSegueWithIdentifier("rotateTestInstructions", sender: self)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        switch (stage) {
        case 1:
            detector.subscribe(.Metrics, callback: rangeMetricsCallback)
            instructionLbl.text = "Now rotate as far as you can clockwise. Then back anti-clockwise, keep your finger held down."
            break
        case 2:
            let touch = touches.first
            
            if (touch!.view == rotateImage) {
                touchTime = NSDate.timeIntervalSinceReferenceDate()
                detector.subscribe(.Metrics, callback: imageMetricsCallback)
            }
            break
        default:
            break
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        switch (stage) {
        case 1:
            if ((maxValue - minValue) >= 10) {
                detector.clearSubscriptions()
                setNextView()
            } else {
                instructionLbl.text = "Insufficient rotation range demonstrated.\nPlease try again."
            }
            break
        case 2:
            detector.clearSubscriptions()
            let touch = touches.first
            
            if (touch!.view == rotateImage) {
                let placeholderDegrees = atan2f(Float(placeholderImage.transform.b), Float(placeholderImage.transform.a)) * Float(180 / M_PI)
                let imageDegrees = atan2f(Float(rotateImage.transform.b), Float(rotateImage.transform.a)) * Float(180 / M_PI)
                let time = NSDate.timeIntervalSinceReferenceDate()
                
                logEvalData("\(participant),\(time),\(maxValue),\(minValue),\(placeholderDegrees),\(angleDifference),\(imageDegrees),\(time - touchTime)")
                setNextView()
                evalCount++
            }
            break
        default:
            break
        }
    }
    
    private func rangeMetricsCallback(data:Float?) {
        if (self.maxValue < self.detector.currentRoll) {
            self.maxValue = self.detector.currentRoll
            self.rightBar.setProgress(self.maxValue / 180, animated: true)
        }
        
        if (self.minValue > self.detector.currentRoll) {
            self.minValue = self.detector.currentRoll
            self.leftBar.setProgress((-self.minValue) / 180, animated: true)
        }
    }
    
    private func imageMetricsCallback(data:Float?) {
        self.rotateImage.transform = CGAffineTransformRotate(self.lastTransform, CGFloat(self.detector.currentRoll) * CGFloat(M_PI / 180))
    }
    
    private func randomiseImages() {
        let range = UInt32(maxValue - minValue)
        let placeholderAngle = Float(Int(arc4random_uniform(range))) + minValue
        let rotateAngle = Float(Int(arc4random_uniform(range))) + minValue
        placeholderImage.transform = CGAffineTransformMakeRotation(CGFloat(MathUtils.deg2rad(placeholderAngle)))
        rotateImage.transform = CGAffineTransformMakeRotation(CGFloat(MathUtils.deg2rad(rotateAngle)))
        angleDifference = placeholderAngle - rotateAngle
        lastTransform = rotateImage.transform
        
        if angleDifference < minAngle {
            randomiseImages()
        }
    }
    
    private func setNextView() {
        placeholderImage.hidden = true
        rotateImage.hidden = true
        instructionLbl.hidden = false
        instructionLbl.text = "Press next to advance to the next stage."
        self.view.userInteractionEnabled = false
    }
    
    private func setRotateImage() {
        instructionLbl.hidden = true
        leftBar.hidden = true
        rightBar.hidden = true
        placeholderImage.hidden = false
        rotateImage.hidden = false
        
        randomiseImages()
        self.view.userInteractionEnabled = true
    }
    
    @IBAction func next(sender: AnyObject) {
        switch (stage) {
        case 1:
            setRotateImage()
            stage++
            break
        case 2:
            if (evalCount < 10) {
                setRotateImage()
            } else {
                nextBtn.enabled = false
                instructionLbl.hidden = false
                placeholderImage.hidden = true
                rotateImage.hidden = true
                instructionLbl.text = "Evaluation Complete. Thank you."
                stage++
                logSensorData()
                evalVC.completeRoll(csv)
            }
            progressBar.setProgress(Float(evalCount) / 10.0, animated: true)
            break
        default:
            break
        }
    }
    
    @IBAction func unwindToRollEval(segue:UIStoryboardSegue) {}
}