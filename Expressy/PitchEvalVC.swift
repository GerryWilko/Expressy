//
//  PitchEvalVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 08/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit

class PitchEvalVC: EvaluationVC {
    fileprivate var stage:Int
    fileprivate var maxValue:Float
    fileprivate var minValue:Float
    fileprivate var evalCount:Int
    fileprivate var lastTransform:CGAffineTransform!
    fileprivate var reqPitchAngle:Float!
    fileprivate var touchTime:TimeInterval!
    
    @IBOutlet weak var leftBarTop: UIProgressView!
    @IBOutlet weak var leftBarBottom: UIProgressView!
    @IBOutlet weak var rightBarTop: UIProgressView!
    @IBOutlet weak var rightBarBottom: UIProgressView!
    
    required init?(coder aDecoder: NSCoder) {
        stage = 1
        maxValue = 0.0
        minValue = 0.0
        evalCount = 0
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCSV("pitch", headerLine: "Participant ID,Time,Max Angle,Min Angle,Requested Angle,End Angle,Time Taken")
        leftBarTop.transform = CGAffineTransform(rotationAngle: -CGFloat(M_PI / 2))
        rightBarTop.transform = CGAffineTransform(rotationAngle: -CGFloat(M_PI / 2))
        leftBarBottom.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / 2))
        rightBarBottom.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / 2))
        self.performSegue(withIdentifier: "pitchTestInstructions", sender: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        switch (stage) {
        case 1:
            detector.subscribe(.metrics, callback: rangeMetricsCallback)
            instructionLbl.text = "Now pitch upwards as far as you can.\nThen back to the downwards again, keep your finger held down."
            break
        case 2:
            touchTime = Date.timeIntervalSinceReferenceDate
            detector.subscribe(.metrics, callback: testMetricsCallback)
            break
        default:
            break
        }
    }
    
    fileprivate func rangeMetricsCallback(_ data:Float?) {
        if (self.maxValue < self.detector.currentPitch) {
            self.maxValue = self.detector.currentPitch
            self.leftBarTop.setProgress(self.maxValue / 90, animated: false)
        }
        
        if (self.minValue > self.detector.currentPitch) {
            self.minValue = self.detector.currentPitch
            self.leftBarBottom.setProgress((-self.minValue) / 90, animated: false)
        }
    }
    
    fileprivate func testMetricsCallback(_ data:Float?) {
        if (self.detector.currentPitch > 0) {
            self.leftBarTop.setProgress(self.detector.currentPitch / 90, animated: false)
            self.leftBarBottom.setProgress(0.0, animated: false)
        } else {
            self.leftBarBottom.setProgress((-self.detector.currentPitch) / 90, animated: false)
            self.leftBarTop.setProgress(0.0, animated: false)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let pitch = detector.currentPitch
        super.touchesEnded(touches, with: event)
        
        let time = Date.timeIntervalSinceReferenceDate
        
        switch (stage) {
        case 1:
            detector.clearSubscriptions()
            setNextView()
            break
        case 2:
            detector.clearSubscriptions()
            logEvalData("\(participant),\(time),\(maxValue),\(minValue),\(reqPitchAngle),\(pitch),\(time - touchTime)")
            setNextView()
            evalCount += 1
            break
        default:
            break
        }
    }
    
    fileprivate func setRandomPitch() {
        let range = UInt32(maxValue - minValue)
        let randomPitch = Float(Int(arc4random_uniform(range))) + minValue
        if (randomPitch > 0) {
            rightBarTop.setProgress(randomPitch / 90, animated: true)
            rightBarBottom.setProgress(0.0, animated: true)
        } else {
            rightBarBottom.setProgress((-randomPitch) / 90, animated: true)
            rightBarTop.setProgress(0.0, animated: true)
        }
        
        reqPitchAngle = randomPitch
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        detector.stopDetection()
    }
    
    fileprivate func setNextView() {
        instructionLbl.text = "Press next to advance to the next stage."
        self.view.isUserInteractionEnabled = false
    }
    
    fileprivate func setPitchView() {
        leftBarTop.setProgress(0.0, animated: false)
        leftBarBottom.setProgress(0.0, animated: false)
        rightBarTop.setProgress(0.0, animated: false)
        rightBarBottom.setProgress(0.0, animated: false)
        setRandomPitch()
        instructionLbl.text = "Pitch to the angle demonstrated on the right."
        self.view.isUserInteractionEnabled = true
    }
    
    @IBAction func next(_ sender: AnyObject) {
        switch (stage) {
        case 1:
            rightBarTop.isHidden = false
            rightBarBottom.isHidden = false
            setPitchView()
            stage += 1
            break
        case 2:
            if (evalCount < 10) {
                setPitchView()
            } else {
                nextBtn.isEnabled = false
                instructionLbl.text = "Evaluation Complete. Thank you."
                logSensorData()
                evalVC.completePitch(csv)
                stage += 1
            }
            progressBar.setProgress(Float(evalCount) / 10.0, animated: true)
            break
        default:
            break
        }
    }
    
    @IBAction func unwindToPitchEval(_ segue:UIStoryboardSegue) {}
}
