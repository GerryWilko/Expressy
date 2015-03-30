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
    private var angleDifference:Float!
    
    private let detector:InteractionDetector
    private let csvBuilder:CSVBuilder
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var placeholderImage: UIImageView!
    @IBOutlet weak var rotateImage: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        evalCount = 0
        csvBuilder = CSVBuilder(fileNames: ["timeRotate.csv","timeRotateData.csv"], headerLines: ["Time,Angle to Rotate,Placeholder Angle,Image Angle", "Time,ax,ay,az,gx,gy,gz,mx,my,mz,gravx,gravy,gravz,yaw,pitch,roll"])
        started = false
        super.init(coder: aDecoder)
        detector.startDetection()
    }
    
    override func viewDidLoad() {
        self.performSegueWithIdentifier("timeRotateInstructions", sender: self)
        randomiseImages()
        lastTransform = rotateImage.transform
        WaxProcessor.getProcessor().dataCache.subscribe(dataCallback)
    }
    
    func randomiseImages() {
        let placeholderAngle = Float(Int(arc4random_uniform(360)))
        let rotateAngle = Float(Int(arc4random_uniform(360)))
        placeholderImage.transform = CGAffineTransformMakeRotation(CGFloat(placeholderAngle))
        rotateImage.transform = CGAffineTransformMakeRotation(CGFloat(rotateAngle))
        angleDifference = placeholderAngle - rotateAngle
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        
        if (touch.view == rotateImage) {
            if (!started) {
                started = true
                startTime = NSDate.timeIntervalSinceReferenceDate()
            }
            
            detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
            detector.subscribe(EventType.Metrics, callback: {
                self.rotateImage.transform = CGAffineTransformRotate(self.lastTransform, CGFloat(self.detector.currentRotation) * CGFloat(M_PI / 180))
            })
        }
    }
    
    func dataCallback(data:WaxData) {
        csvBuilder.appendRow(data.print(), index: 1)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
        detector.clearSubscriptions()
        
        let placeholderDegrees = atan2f(Float(placeholderImage.transform.b), Float(placeholderImage.transform.a)) * Float(180 / M_PI)
        let imageDegrees = atan2f(Float(rotateImage.transform.b), Float(rotateImage.transform.a)) * Float(180 / M_PI)
        
        if (fabs(placeholderDegrees - imageDegrees) < 2) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            let time = NSDate.timeIntervalSinceReferenceDate() - startTime
            
            csvBuilder.appendRow("\(time),\(angleDifference),\(placeholderDegrees),\(imageDegrees)", index: 0)
            
            if (evalCount < 10) {
                randomiseImages()
                evalCount++
                started = false
            } else if (evalCount == 10) {
                WaxProcessor.getProcessor().dataCache.clearSubscriptions()
                placeholderImage.hidden = true
                rotateImage.hidden = true
                instructionLbl.hidden = false
                csvBuilder.emailCSV(self, subject: "Time to Rotate Evaluation")
            }
            
            progressBar.setProgress(Float(evalCount) / 10.0, animated: true)
        }
        
        lastTransform = rotateImage.transform
    }
}