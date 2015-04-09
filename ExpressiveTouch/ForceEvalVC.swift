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
    private var startTime:NSTimeInterval!
    private var reqTouchForce:UInt32!
    
    private let detector:InteractionDetector
    private let csvBuilder:CSVBuilder
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var forceImage: UIImageView!
    @IBOutlet weak var forceGuide: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        stage = 1
        evalCount = 0
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        detector.startDetection()
        csvBuilder = CSVBuilder(fileNames: ["force.csv", "forceData.csv"], headerLines: ["Time,Requested Force,Tapped Force", WaxData.headerLine()])
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.performSegueWithIdentifier("forceInstructions", sender: self)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let time = NSDate.timeIntervalSinceReferenceDate()
        detector.touchDown(time)
        let touchForce = detector.calculateTouchForce(time) * 20
        UIView.animateWithDuration(1.0, animations: {
            self.forceImage.transform = CGAffineTransformMakeScale(CGFloat(touchForce), CGFloat(touchForce))
        })
        
        println(touchForce)
        
        if (stage == 2) {
            self.view.userInteractionEnabled = false
            csvBuilder.appendRow("\(time),\(reqTouchForce),\(touchForce)", index: 0)
            instructionLbl.text = "Press next to advance to next stage."
            evalCount++
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        detector.stopDetection()
    }
    
    func setRandomForce() {
        reqTouchForce = arc4random_uniform(25)
        UIView.animateWithDuration(1.0, animations: {
            self.forceGuide.transform = CGAffineTransformMakeScale(CGFloat(self.reqTouchForce), CGFloat(self.reqTouchForce))
        })
    }
    
    @IBAction func next(sender: AnyObject) {
        switch (stage) {
        case 1:
            startTime = NSDate.timeIntervalSinceReferenceDate()
            forceGuide.hidden = false
            setRandomForce()
            instructionLbl.text = "Tap the screen with a force to match the blue circle."
            stage++
            break
        case 2:
            if (evalCount < 10) {
                progressBar.setProgress(Float(evalCount) / 10.0, animated: true)
                setRandomForce()
                self.view.userInteractionEnabled = true
                instructionLbl.text = "Tap the screen with a force to match the blue circle."
            } else {
                progressBar.setProgress(1, animated: true)
                EvalUtils.logDataBetweenTimes(startTime, endTime: NSDate.timeIntervalSinceReferenceDate(), csv: csvBuilder)
                instructionLbl.text = "Evaluation Complete. Thank you."
                csvBuilder.emailCSV(self, subject: "Force Evaluation")
                stage++
            }
            break
        default:
            break
        }
    }
}