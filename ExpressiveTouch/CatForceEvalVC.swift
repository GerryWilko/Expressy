//
//  CatForceEvalVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 26/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class CatForceEvalVC: EvaluationVC {
    private var runStack:[ForceCategory]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCSV("catForce", headerLine: "Participant ID,Time,Requested Force,Tap Force")
        runStack = buildRunStack()
        self.performSegueWithIdentifier("tapForceInstructions", sender: self)
        
        detector.subscribe(.AllPress) { (data) -> Void in
            let time = NSDate.timeIntervalSinceReferenceDate()
            
            switch (self.runStack[0]) {
            case .Soft:
                self.logEvalData("\(self.participant),\(time),Soft,\(data!)")
                break
            case .Medium:
                self.logEvalData("\(self.participant),\(time),Medium,\(data!)")
                break
            case .Hard:
                self.logEvalData("\(self.participant),\(time),Hard,\(data!)")
                break
            }
            
            self.setNextView()
        }
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
        }
        
        self.view.userInteractionEnabled = true
    }
    
    @IBAction func next(sender: AnyObject) {
        if (runStack.isEmpty){
            nextBtn.enabled = false
            progressBar.setProgress(1.0, animated: true)
            instructionLbl.text = "Evaluation Complete. Thank you."
            instructionLbl.textColor = UIColor.blackColor()
            logSensorData()
            evalVC.completeCatForce(csv)
        } else {
            setTapView()
        }
        
        progressBar.setProgress(Float(Float(30 - runStack.count) / 30.0), animated: true)
    }
    
    @IBAction func unwindToCatForceEval(segue:UIStoryboardSegue) {}
}

private enum ForceCategory {
    case Soft, Medium, Hard
}