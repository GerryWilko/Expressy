//
//  PitchEvalVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 08/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class PitchEvalVC: EvaluationVC {
    private var stage:Int
    private var maxValue:Float
    private var minValue:Float
    private var evalCount:Int
    private var lastTransform:CGAffineTransform!
    private var reqPitchAngle:Float!
    private var touchTime:NSTimeInterval!
    
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
        leftBarTop.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI / 2))
        rightBarTop.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI / 2))
        leftBarBottom.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2))
        rightBarBottom.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2))
        self.performSegueWithIdentifier("pitchTestInstructions", sender: self)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        switch (stage) {
        case 1:
            detector.subscribe(EventType.Metrics, callback: rangeMetricsCallback)
            instructionLbl.text = "Now pitch upwards as far as you can.\nThen back to the downwards again, keep your finger held down."
            break
        case 2:
            touchTime = NSDate.timeIntervalSinceReferenceDate()
            detector.subscribe(EventType.Metrics, callback: testMetricsCallback)
            break
        default:
            break
        }
    }
    
    private func rangeMetricsCallback(data:Float?) {
        if (self.maxValue < self.detector.currentPitch) {
            self.maxValue = self.detector.currentPitch
            self.leftBarTop.setProgress(self.maxValue / 90, animated: false)
        }
        
        if (self.minValue > self.detector.currentPitch) {
            self.minValue = self.detector.currentPitch
            self.leftBarBottom.setProgress((-self.minValue) / 90, animated: false)
        }
    }
    
    private func testMetricsCallback(data:Float?) {
        if (self.detector.currentPitch > 0) {
            self.leftBarTop.setProgress(self.detector.currentPitch / 90, animated: false)
            self.leftBarBottom.setProgress(0.0, animated: false)
        } else {
            self.leftBarBottom.setProgress((-self.detector.currentPitch) / 90, animated: false)
            self.leftBarTop.setProgress(0.0, animated: false)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        let time = NSDate.timeIntervalSinceReferenceDate()
        let pitch = detector.currentPitch
        
        switch (stage) {
        case 1:
            detector.clearSubscriptions()
            setNextView()
            break
        case 2:
            detector.clearSubscriptions()
            logEvalData("\(participant),\(time),\(maxValue),\(minValue),\(reqPitchAngle),\(pitch),\(time - touchTime)")
            setNextView()
            evalCount++
            break
        default:
            break
        }
    }
    
    private func setRandomPitch() {
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
    
    override func viewDidDisappear(animated: Bool) {
        detector.stopDetection()
    }
    
    private func setNextView() {
        instructionLbl.text = "Press next to advance to the next stage."
        self.view.userInteractionEnabled = false
    }
    
    private func setPitchView() {
        leftBarTop.setProgress(0.0, animated: false)
        leftBarBottom.setProgress(0.0, animated: false)
        rightBarTop.setProgress(0.0, animated: false)
        rightBarBottom.setProgress(0.0, animated: false)
        setRandomPitch()
        instructionLbl.text = "Pitch to the angle demonstrated on the right."
        self.view.userInteractionEnabled = true
    }
    
    @IBAction func next(sender: AnyObject) {
        switch (stage) {
        case 1:
            rightBarTop.hidden = false
            rightBarBottom.hidden = false
            setPitchView()
            stage++
            break
        case 2:
            if (evalCount < 10) {
                setPitchView()
            } else {
                nextBtn.enabled = false
                instructionLbl.text = "Evaluation Complete. Thank you."
                logSensorData()
                evalVC.completePitch(csv)
                stage++
            }
            progressBar.setProgress(Float(evalCount) / 10.0, animated: true)
            break
        default:
            break
        }
    }
    
    @IBAction func unwindToPitchEval(segue:UIStoryboardSegue) {}
}