//
//  TapEvalVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 26/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import AudioToolbox

class TapEvalVC: UIViewController {
    private var startTime:NSTimeInterval!
    private var runStack:[ForceCategory]!
    private var current:ForceCategory
    
    private let detector:InteractionDetector
    private let csv:CSVBuilder
    
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        csv = CSVBuilder(fileNames: ["tapForce.csv","tapData.csv"], headerLines: ["Time,Requested Force,Tap Force", "Time,ax,ay,az,gx,gy,gz,mx,my,mz,gravx,gravy,gravz,yaw,pitch,roll,Touch,Touch Force"])
        current = ForceCategory.Soft
        super.init(coder: aDecoder)
        detector.startDetection()
        runStack = buildRunStack()
    }
    
    override func viewDidLoad() {
        self.performSegueWithIdentifier("tapForceInstructions", sender: self)
        startTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    override func viewDidDisappear(animated: Bool) {
        detector.stopDetection()
    }
    
    func buildRunStack() -> [ForceCategory] {
        var runStack = [ForceCategory.Medium, ForceCategory.Hard]
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
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        let time = NSDate.timeIntervalSinceReferenceDate()
        detector.touchDown(time)
        let tapForce = detector.calculateTouchForce(time)
        
        progressBar.setProgress(Float(Float(30 - runStack.count) / 30.0), animated: true)
        
        switch (current) {
        case .Soft:
            csv.appendRow("\(time),Soft,\(tapForce)", index: 0)
            break
        case .Medium:
            csv.appendRow("\(time),Medium,\(tapForce)", index: 0)
            break
        case .Hard:
            csv.appendRow("\(time),Hard,\(tapForce)", index: 0)
            break
        default:
            instructionLbl.text = "Something went wrong. Try again."
            break
        }
        
        if (runStack.isEmpty){
            detector.stopDetection()
            WaxProcessor.getProcessor().dataCache.clearSubscriptions()
            progressBar.setProgress(1.0, animated: true)
            instructionLbl.text = "Evaluation Complete. Thank you."
            instructionLbl.textColor = UIColor.blackColor()
            EvalUtils.logDataBetweenTimes(startTime, endTime: time, csv: csv)
            csv.emailCSV(self, subject: "Tap Force Evaluation")
        } else {
            current = runStack[0]
            runStack.removeAtIndex(0)
            
            switch (current) {
            case .Soft:
                instructionLbl.text = "Tap the screen: Soft"
                instructionLbl.textColor = UIColor.blueColor()
                break
            case .Medium:
                instructionLbl.text = "Tap the screen: Medium"
                instructionLbl.textColor = UIColor.greenColor()
                break
            case .Hard:
                instructionLbl.text = "Tap the screen: Hard"
                instructionLbl.textColor = UIColor.orangeColor()
                break
            default:
                instructionLbl.text = "Something went wrong. Try again."
                instructionLbl.textColor = UIColor.blackColor()
                break
            }
        }
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
    
    @IBAction func next(sender: AnyObject) {
    }
}

enum ForceCategory {
    case Soft, Medium, Hard
}