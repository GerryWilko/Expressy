//
//  PitchTestEvalVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 08/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class PitchTestEvalVC: UIViewController {
    private var stage:Int
    private var maxValue:Float
    private var minValue:Float
    private var evalCount:Int
    private var startTime:NSTimeInterval!
    private var lastTransform:CGAffineTransform!
    private var reqPitchAngle:Float!
    
    private let detector:InteractionDetector
    private let csvBuilder:CSVBuilder
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var leftBarTop: UIProgressView!
    @IBOutlet weak var leftBarBottom: UIProgressView!
    @IBOutlet weak var rightBarTop: UIProgressView!
    @IBOutlet weak var rightBarBottom: UIProgressView!
    
    required init(coder aDecoder: NSCoder) {
        stage = 1
        maxValue = 0.0
        minValue = 0.0
        evalCount = 0
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        detector.startDetection()
        csvBuilder = CSVBuilder(fileNames: ["rotate.csv", "rotateData.csv"], headerLines: ["Time,Max Angle,Min Angle,Requested Angle,End Angle", WaxData.headerLine()])
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        leftBarTop.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI / 2))
        rightBarTop.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI / 2))
        leftBarBottom.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2))
        rightBarBottom.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2))
        
        self.performSegueWithIdentifier("pitchTestInstructions", sender: self)
        startTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
        
        switch (stage) {
        case 1:
            detector.subscribe(EventType.Metrics, callback: {
                if (self.maxValue < self.detector.currentPitch) {
                    self.maxValue = self.detector.currentPitch
                    self.leftBarTop.setProgress(self.maxValue / 90, animated: true)
                }
                
                if (self.minValue > self.detector.currentPitch) {
                    self.minValue = self.detector.currentPitch
                    self.leftBarBottom.setProgress((-self.minValue) / 90, animated: true)
                }
            })
            instructionLbl.text = "Now pitch upwards as far as you can.\nThen back to the downwards again, keep your finger held down."
            break
        case 2:
            detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
            detector.subscribe(EventType.Metrics, callback: {
                if (self.detector.currentPitch > 0) {
                    self.leftBarTop.setProgress(self.detector.currentPitch / 90, animated: true)
                    self.leftBarBottom.setProgress(0.0, animated: true)
                } else {
                    self.leftBarBottom.setProgress((-self.detector.currentPitch) / 90, animated: true)
                    self.leftBarTop.setProgress(0.0, animated: true)
                }
            })
            break
        default:
            break
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let time = NSDate.timeIntervalSinceReferenceDate()
        detector.touchUp(time)
        
        switch (stage) {
        case 1:
            detector.clearSubscriptions()
            instructionLbl.text = "Press next to advance to the next stage or try again."
            self.view.userInteractionEnabled = false
            break
        case 2:
            detector.clearSubscriptions()
            csvBuilder.appendRow("\(time),\(maxValue),\(minValue),\(reqPitchAngle),\(detector.currentPitch)", index: 0)
            
            evalCount++
            instructionLbl.text = "Press next to advance to the next step."
            break
        default:
            break
        }
    }
    
    func setRandomPitch() {
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
    
    @IBAction func next(sender: AnyObject) {
        switch (stage) {
        case 1:
            rightBarTop.hidden = false
            rightBarBottom.hidden = false
            setRandomPitch()
            self.view.userInteractionEnabled = true
            stage++
            break
        case 2:
            if (evalCount < 10) {
                progressBar.setProgress(Float(evalCount) / 10.0, animated: true)
                setRandomPitch()
                self.view.userInteractionEnabled = true
                instructionLbl.text = "Pitch to the angle demonstrated on the right."
            } else {
                progressBar.setProgress(1.0, animated: true)
                instructionLbl.text = "Evaluation Complete. Thank you."
                EvalUtils.logDataBetweenTimes(startTime, endTime: NSDate.timeIntervalSinceReferenceDate(), csv: csvBuilder)
                stage++
            }
            break
        default:
            break
        }
    }
}