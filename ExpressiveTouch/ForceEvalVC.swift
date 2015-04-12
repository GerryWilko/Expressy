//
//  ForceEvalVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 08/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class ForceEvalVC: UIViewController {
    private var stage:Int
    private var evalCount:Int
    private var attemptCount:Int!
    private var startTime:NSTimeInterval!
    private var reqTouchForce:UInt32!
    
    private let scaleFactor = 20
    private let detector:InteractionDetector
    private let csvBuilder:CSVBuilder
    private let participant:UInt32
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var forceImage: UIImageView!
    @IBOutlet weak var forceGuide: UIImageView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    required init(coder aDecoder: NSCoder) {
        stage = 1
        evalCount = 0
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        detector.startDetection()
        participant = EvalUtils.generateParticipantID()
        csvBuilder = CSVBuilder(fileNames: ["force-\(participant).csv", "forceData-\(participant).csv"], headerLines: ["Participant ID,Time,Requested Force,Attempt,Tapped Force", WaxData.headerLine()])
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.performSegueWithIdentifier("forceInstructions", sender: self)
        startTime = NSDate.timeIntervalSinceReferenceDate()
        navBar.title = "\(navBar.title!) \(participant)"
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let time = NSDate.timeIntervalSinceReferenceDate()
        detector.touchDown(time)
        let touchForce = detector.calculateTouchForce(time)
        
        UIView.animateWithDuration(1.0, animations: {
            self.forceImage.transform = CGAffineTransformMakeScale(CGFloat(touchForce * Float(self.scaleFactor)), CGFloat(touchForce * Float(self.scaleFactor)))
        }, completion: {
            (value: Bool) in
            UIView.animateWithDuration(1.0, animations: {
                self.forceImage.transform = CGAffineTransformMakeScale(0.01, 0.01)
            })
        })
        
        if (stage == 2) {
            csvBuilder.appendRow("\(participant),\(time),\(reqTouchForce / UInt32(scaleFactor)),\(attemptCount + 1),\(touchForce)", index: 0)
            if (attemptCount == 2) {
                setNextView()
                evalCount++
            } else {
                attemptCount = attemptCount + 1
                instructionLbl.text = "Attempt: \(attemptCount! + 1)"
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
    }
    
    override func viewDidDisappear(animated: Bool) {
        detector.stopDetection()
    }
    
    func setRandomForce() {
        attemptCount = 0
        reqTouchForce = arc4random_uniform(20) + 1
        UIView.animateWithDuration(1.0, animations: {
            self.forceGuide.transform = CGAffineTransformMakeScale(CGFloat(self.reqTouchForce), CGFloat(self.reqTouchForce))
        })
    }
    
    func setNextView() {
        self.view.userInteractionEnabled = false
        instructionLbl.text = "Press next to advance to next stage."
    }
    
    func setForceView() {
        forceGuide.hidden = false
        setRandomForce()
        instructionLbl.text = "Tap the screen with a force to match the blue circle."
        self.view.userInteractionEnabled = true
    }
    
    @IBAction func next(sender: AnyObject) {
        switch (stage) {
        case 1:
            setForceView()
            stage++
            break
        case 2:
            if (evalCount < 10) {
                setForceView()
            } else {
                EvalUtils.logDataBetweenTimes(startTime, endTime: NSDate.timeIntervalSinceReferenceDate(), csv: csvBuilder)
                instructionLbl.text = "Evaluation Complete. Thank you."
                csvBuilder.emailCSV(self, subject: "Force Evaluation: \(participant)")
                stage++
            }
            progressBar.setProgress(Float(evalCount) / 10.0, animated: true)
            break
        default:
            break
        }
    }
}