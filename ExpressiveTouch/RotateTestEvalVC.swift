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
    private var startTime:NSTimeInterval!
    private var angleDifference:Float!
    private var lastTransform:CGAffineTransform!
    private var touchTime:NSTimeInterval!
    
    private let minAngle:Float = 5.0
    private let detector:InteractionDetector
    private let csvBuilder:CSVBuilder
    private let participant:UInt32
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var placeholderImage: UIImageView!
    @IBOutlet weak var rotateImage: UIImageView!
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var leftBar: UIProgressView!
    @IBOutlet weak var rightBar: UIProgressView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var nextBtn: UIBarButtonItem!
    
    required init(coder aDecoder: NSCoder) {
        stage = 1
        maxValue = 0.0
        minValue = 0.0
        evalCount = 0
        detector = InteractionDetector(dataCache: SensorProcessor.getProcessor().dataCache)
        detector.startDetection()
        participant = EvalUtils.generateParticipantID()
        csvBuilder = CSVBuilder(fileNames: ["rotate-\(participant).csv", "rotateData-\(participant).csv"], headerLines: ["Participant ID,Time,Max Angle,Min Angle,Placeholder Angle,Angle to Rotate,End Image Angle,Time Taken", SensorData.headerLine()])
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
        
        switch (stage) {
        case 1:
            detector.subscribe(EventType.Metrics, callback: rangeMetricsCallback)
            instructionLbl.text = "Now rotate as far as you can clockwise. Then back anti-clockwise, keep your finger held down."
            break
        case 2:
            let touch = touches.first as! UITouch
            
            if (touch.view == rotateImage) {
                touchTime = NSDate.timeIntervalSinceReferenceDate()
                detector.subscribe(EventType.Metrics, callback: imageMetricsCallback)
            }
            break
        default:
            break
        }
    }
    
    private func rangeMetricsCallback(data:Float!) {
        if (self.maxValue < self.detector.currentRotation) {
            self.maxValue = self.detector.currentRotation
            self.rightBar.setProgress(self.maxValue / 180, animated: true)
        }
        
        if (self.minValue > self.detector.currentRotation) {
            self.minValue = self.detector.currentRotation
            self.leftBar.setProgress((-self.minValue) / 180, animated: true)
        }
    }
    
    private func imageMetricsCallback(data:Float!) {
        self.rotateImage.transform = CGAffineTransformRotate(self.lastTransform, CGFloat(self.detector.currentRotation) * CGFloat(M_PI / 180))
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let time = NSDate.timeIntervalSinceReferenceDate()
        detector.touchUp(time)
        
        switch (stage) {
        case 1:
            detector.clearSubscriptions()
            setNextView()
            break
        case 2:
            detector.clearSubscriptions()
            let touch = touches.first as! UITouch
            
            if (touch.view == rotateImage) {
                let placeholderDegrees = atan2f(Float(placeholderImage.transform.b), Float(placeholderImage.transform.a)) * Float(180 / M_PI)
                let imageDegrees = atan2f(Float(rotateImage.transform.b), Float(rotateImage.transform.a)) * Float(180 / M_PI)
                csvBuilder.appendRow("\(participant),\(time),\(maxValue),\(minValue),\(placeholderDegrees),\(angleDifference),\(imageDegrees),\(time - touchTime)", index: 0)
                setNextView()
                evalCount++
            }
            break
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        leftBar.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        self.performSegueWithIdentifier("rotateTestInstructions", sender: self)
        startTime = NSDate.timeIntervalSinceReferenceDate()
        navBar.title = "\(navBar.title!) \(participant)"
    }
    
    override func viewDidDisappear(animated: Bool) {
        detector.stopDetection()
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
                EvalUtils.logDataBetweenTimes(startTime, endTime: NSDate.timeIntervalSinceReferenceDate(), csv: csvBuilder)
                instructionLbl.text = "Evaluation Complete. Thank you."
                csvBuilder.emailCSV(self, subject: "Rotation test evaluation: \(participant)")
                stage++
            }
            progressBar.setProgress(Float(evalCount) / 10.0, animated: true)
            break
        default:
            break
        }
    }
}