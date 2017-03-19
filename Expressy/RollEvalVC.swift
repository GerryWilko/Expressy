//
//  RollEvalVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 08/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit

class RollEvalVC: EvaluationVC {
    fileprivate var stage:Int
    fileprivate var maxValue:Float
    fileprivate var minValue:Float
    fileprivate var evalCount:Int
    fileprivate var angleDifference:Float!
    fileprivate var lastTransform:CGAffineTransform!
    fileprivate var touchTime:TimeInterval!
    
    fileprivate let minAngle:Float = 5.0
    
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
        leftBar.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        self.performSegue(withIdentifier: "rotateTestInstructions", sender: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        switch (stage) {
        case 1:
            detector.subscribe(.metrics, callback: rangeMetricsCallback)
            instructionLbl.text = "Now rotate as far as you can clockwise. Then back anti-clockwise, keep your finger held down."
            break
        case 2:
            let touch = touches.first
            
            if (touch!.view == rotateImage) {
                touchTime = Date.timeIntervalSinceReferenceDate
                detector.subscribe(.metrics, callback: imageMetricsCallback)
            }
            break
        default:
            break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
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
                let time = Date.timeIntervalSinceReferenceDate
                
                logEvalData("\(participant),\(time),\(maxValue),\(minValue),\(placeholderDegrees),\(angleDifference),\(imageDegrees),\(time - touchTime)")
                setNextView()
                evalCount += 1
            }
            break
        default:
            break
        }
    }
    
    fileprivate func rangeMetricsCallback(_ data:Float?) {
        if (self.maxValue < self.detector.currentRoll) {
            self.maxValue = self.detector.currentRoll
            self.rightBar.setProgress(self.maxValue / 180, animated: true)
        }
        
        if (self.minValue > self.detector.currentRoll) {
            self.minValue = self.detector.currentRoll
            self.leftBar.setProgress((-self.minValue) / 180, animated: true)
        }
    }
    
    fileprivate func imageMetricsCallback(_ data:Float?) {
        self.rotateImage.transform = self.lastTransform.rotated(by: CGFloat(self.detector.currentRoll) * CGFloat(M_PI / 180))
    }
    
    fileprivate func randomiseImages() {
        let range = UInt32(maxValue - minValue)
        let placeholderAngle = Float(Int(arc4random_uniform(range))) + minValue
        let rotateAngle = Float(Int(arc4random_uniform(range))) + minValue
        placeholderImage.transform = CGAffineTransform(rotationAngle: CGFloat(MathUtils.deg2rad(placeholderAngle)))
        rotateImage.transform = CGAffineTransform(rotationAngle: CGFloat(MathUtils.deg2rad(rotateAngle)))
        angleDifference = placeholderAngle - rotateAngle
        lastTransform = rotateImage.transform
        
        if angleDifference < minAngle {
            randomiseImages()
        }
    }
    
    fileprivate func setNextView() {
        placeholderImage.isHidden = true
        rotateImage.isHidden = true
        instructionLbl.isHidden = false
        instructionLbl.text = "Press next to advance to the next stage."
        self.view.isUserInteractionEnabled = false
    }
    
    fileprivate func setRotateImage() {
        instructionLbl.isHidden = true
        leftBar.isHidden = true
        rightBar.isHidden = true
        placeholderImage.isHidden = false
        rotateImage.isHidden = false
        
        randomiseImages()
        self.view.isUserInteractionEnabled = true
    }
    
    @IBAction func next(_ sender: AnyObject) {
        switch (stage) {
        case 1:
            setRotateImage()
            stage += 1
            break
        case 2:
            if (evalCount < 10) {
                setRotateImage()
            } else {
                nextBtn.isEnabled = false
                instructionLbl.isHidden = false
                placeholderImage.isHidden = true
                rotateImage.isHidden = true
                instructionLbl.text = "Evaluation Complete. Thank you."
                stage += 1
                logSensorData()
                evalVC.completeRoll(csv)
            }
            progressBar.setProgress(Float(evalCount) / 10.0, animated: true)
            break
        default:
            break
        }
    }
    
    @IBAction func unwindToRollEval(_ segue:UIStoryboardSegue) {}
}
