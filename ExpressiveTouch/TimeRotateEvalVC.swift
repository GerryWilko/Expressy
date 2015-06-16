//
//  TimeRotateEvalVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 30/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import AudioToolbox

class TimeRotateEvalVC: UIViewController {
    private var lastTransform:CGAffineTransform!
    private var evalCount:Int
    private var started:Bool
    private var startTime:NSTimeInterval!
    private var rotationStartTime:NSTimeInterval!
    private var angleDifference:Float!
    
    private let detector:InteractionDetector
    private let csvBuilder:CSVBuilder
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var placeholderImage: UIImageView!
    @IBOutlet weak var rotateImage: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: SensorProcessor.dataCache)
        evalCount = 0
        csvBuilder = CSVBuilder(fileNames: ["timeRotate.csv","timeRotateData.csv"], headerLines: ["Start Time,Complete Time,Time to Complete,Angle to Rotate,Placeholder Angle,Image Angle", SensorData.headerLine()])
        started = false
        super.init(coder: aDecoder)
        detector.startDetection()
    }
    
    override func viewDidLoad() {
        self.performSegueWithIdentifier("timeRotateInstructions", sender: self)
        randomiseImages()
        lastTransform = rotateImage.transform
        startTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    func randomiseImages() {
        let placeholderAngle = Float(Int(arc4random_uniform(360)))
        let rotateAngle = Float(Int(arc4random_uniform(360)))
        placeholderImage.transform = CGAffineTransformMakeRotation(CGFloat(placeholderAngle))
        rotateImage.transform = CGAffineTransformMakeRotation(CGFloat(rotateAngle))
        angleDifference = placeholderAngle - rotateAngle
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        
        if (touch!.view == rotateImage) {
            if (!started) {
                started = true
                rotationStartTime = NSDate.timeIntervalSinceReferenceDate()
            }
            
            detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
            detector.subscribe(EventType.Metrics, callback: metricsCallback)
        }
    }
    
    private func metricsCallback(data:Float!) {
        self.rotateImage.transform = CGAffineTransformRotate(self.lastTransform, CGFloat(self.detector.currentRotation) * CGFloat(M_PI / 180))
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
        detector.clearSubscriptions()
        
        let placeholderDegrees = atan2f(Float(placeholderImage.transform.b), Float(placeholderImage.transform.a)) * Float(180 / M_PI)
        let imageDegrees = atan2f(Float(rotateImage.transform.b), Float(rotateImage.transform.a)) * Float(180 / M_PI)
        
        if (fabs(placeholderDegrees - imageDegrees) < 2) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            let endTime = NSDate.timeIntervalSinceReferenceDate()
            let timeToComplete = endTime - rotationStartTime
            
            csvBuilder.appendRow("\(rotationStartTime),\(endTime),\(timeToComplete),\(angleDifference),\(placeholderDegrees),\(imageDegrees)", index: 0)
            
            if (evalCount < 10) {
                randomiseImages()
                evalCount++
                started = false
            } else if (evalCount == 10) {
                SensorProcessor.dataCache.clearSubscriptions()
                placeholderImage.hidden = true
                rotateImage.hidden = true
                instructionLbl.hidden = false
                EvalUtils.logDataBetweenTimes(startTime, endTime: NSDate.timeIntervalSinceReferenceDate(), csv: csvBuilder)
                csvBuilder.emailCSV(self, subject: "Time to Rotate Evaluation")
            }
            
            progressBar.setProgress(Float(evalCount) / 10.0, animated: true)
        }
        
        lastTransform = rotateImage.transform
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "timeRotateInstructions" {
            let destVC = segue.destinationViewController as! EvalInstructionsVC
            destVC.videoPath = "Time to Rotate Demo"
        }
    }
    
    @IBAction func next(sender: AnyObject) {
    }
}