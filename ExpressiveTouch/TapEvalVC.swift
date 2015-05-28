//
//  TapEvalVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 26/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class TapEvalVC: UIViewController {
    private var startTime:NSTimeInterval!
    private var runStack:[ForceCategory]!
    
    private let detector:InteractionDetector
    private let csv:CSVBuilder
    private let participant:UInt32
    
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var nextBtn: UIBarButtonItem!
    
    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: SensorProcessor.getProcessor().dataCache)
        participant = EvalUtils.generateParticipantID()
        csv = CSVBuilder(fileNames: ["tapForce-\(participant).csv","tapData-\(participant).csv"], headerLines: ["Participant ID,Time,Requested Force,Tap Force", SensorData.headerLine()])
        super.init(coder: aDecoder)
        detector.startDetection()
        runStack = buildRunStack()
    }
    
    override func viewDidLoad() {
        navBar.title = navBar.title! + " \(participant)"
        self.performSegueWithIdentifier("tapForceInstructions", sender: self)
        startTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    override func viewDidDisappear(animated: Bool) {
        detector.stopDetection()
    }
    
    private func buildRunStack() -> [ForceCategory] {
        var runStack = [ForceCategory.Soft, ForceCategory.Medium, ForceCategory.Hard]
        var soft = 9, med = 9, hard = 9
        
        while (soft != 0 || med != 0 || hard != 0) {
            let num = Int(arc4random_uniform(3))
            
            if (num == 0 && soft != 0) {
                runStack.append(ForceCategory.Soft)
                soft--
            } else if (num == 1 && med != 0) {
                runStack.append(ForceCategory.Medium)
                med--
            } else if (num == 2 && hard != 0) {
                runStack.append(ForceCategory.Hard)
                hard--
            }
        }
        
        return runStack
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let time = NSDate.timeIntervalSinceReferenceDate()
        detector.touchDown(time)
        let tapForce = detector.calculateTouchForce(time)
        
        switch (runStack[0]) {
        case .Soft:
            csv.appendRow("\(participant),\(time),Soft,\(tapForce)", index: 0)
            break
        case .Medium:
            csv.appendRow("\(participant),\(time),Medium,\(tapForce)", index: 0)
            break
        case .Hard:
            csv.appendRow("\(participant),\(time),Hard,\(tapForce)", index: 0)
            break
        default:
            break
        }
        
        setNextView()
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tapForceInstructions" {
            let destVC = segue.destinationViewController as! EvalInstructionsVC
            destVC.videoPath = "Tap Force Demo"
        }
    }
    
    private func setNextView() {
        runStack.removeAtIndex(0)
        instructionLbl.text = "Press next to advance to next stage."
        instructionLbl.textColor = UIColor.blackColor()
        self.view.userInteractionEnabled = false
    }
    
    private func setTapView() {
        switch (runStack[0]) {
        case .Soft:
            instructionLbl.text = "Tap the screen: Soft"
            instructionLbl.textColor = UIColor.greenColor()
            break
        case .Medium:
            instructionLbl.text = "Tap the screen: Medium"
            instructionLbl.textColor = UIColor.orangeColor()
            break
        case .Hard:
            instructionLbl.text = "Tap the screen: Hard"
            instructionLbl.textColor = UIColor.redColor()
            break
        default:
            instructionLbl.text = "Something went wrong. Try again."
            instructionLbl.textColor = UIColor.blackColor()
            break
        }
        
        self.view.userInteractionEnabled = true
    }
    
    @IBAction func next(sender: AnyObject) {
        if (runStack.isEmpty){
            nextBtn.enabled = false
            progressBar.setProgress(1.0, animated: true)
            instructionLbl.text = "Evaluation Complete. Thank you."
            instructionLbl.textColor = UIColor.blackColor()
            EvalUtils.logDataBetweenTimes(startTime, endTime: NSDate.timeIntervalSinceReferenceDate(), csv: csv)
            csv.emailCSV(self, subject: "Tap Force Evaluation: \(participant)")
        } else {
            setTapView()
        }
        
        progressBar.setProgress(Float(Float(30 - runStack.count) / 30.0), animated: true)
    }
}

private enum ForceCategory {
    case Soft, Medium, Hard
}