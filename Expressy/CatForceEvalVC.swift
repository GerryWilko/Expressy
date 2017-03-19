//
//  CatForceEvalVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 26/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit

class CatForceEvalVC: EvaluationVC {
    fileprivate var runStack:[ForceCategory]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCSV("catForce", headerLine: "Participant ID,Time,Requested Force,Tap Force")
        runStack = buildRunStack()
        self.performSegue(withIdentifier: "tapForceInstructions", sender: self)
        
        detector.subscribe(.allPress) { (data) -> Void in
            let time = Date.timeIntervalSinceReferenceDate
            
            switch (self.runStack[0]) {
            case .soft:
                self.logEvalData("\(self.participant),\(time),Soft,\(data!)")
                break
            case .medium:
                self.logEvalData("\(self.participant),\(time),Medium,\(data!)")
                break
            case .hard:
                self.logEvalData("\(self.participant),\(time),Hard,\(data!)")
                break
            }
            
            self.setNextView()
        }
    }
    
    fileprivate func buildRunStack() -> [ForceCategory] {
        var runStack = [ForceCategory.soft, ForceCategory.medium, ForceCategory.hard]
        var soft = 9, med = 9, hard = 9
        
        while (soft != 0 || med != 0 || hard != 0) {
            let num = Int(arc4random_uniform(3))
            
            if (num == 0 && soft != 0) {
                runStack.append(ForceCategory.soft)
                soft -= 1
            } else if (num == 1 && med != 0) {
                runStack.append(ForceCategory.medium)
                med -= 1
            } else if (num == 2 && hard != 0) {
                runStack.append(ForceCategory.hard)
                hard -= 1
            }
        }
        
        return runStack
    }
    
    fileprivate func setNextView() {
        runStack.remove(at: 0)
        instructionLbl.text = "Press next to advance to next stage."
        instructionLbl.textColor = UIColor.black
        self.view.isUserInteractionEnabled = false
    }
    
    fileprivate func setTapView() {
        switch (runStack[0]) {
        case .soft:
            instructionLbl.text = "Tap the screen: Soft"
            instructionLbl.textColor = UIColor.green
            break
        case .medium:
            instructionLbl.text = "Tap the screen: Medium"
            instructionLbl.textColor = UIColor.orange
            break
        case .hard:
            instructionLbl.text = "Tap the screen: Hard"
            instructionLbl.textColor = UIColor.red
            break
        }
        
        self.view.isUserInteractionEnabled = true
    }
    
    @IBAction func next(_ sender: AnyObject) {
        if (runStack.isEmpty){
            nextBtn.isEnabled = false
            progressBar.setProgress(1.0, animated: true)
            instructionLbl.text = "Evaluation Complete. Thank you."
            instructionLbl.textColor = UIColor.black
            logSensorData()
            evalVC.completeCatForce(csv)
        } else {
            setTapView()
        }
        
        progressBar.setProgress(Float(Float(30 - runStack.count) / 30.0), animated: true)
    }
    
    @IBAction func unwindToCatForceEval(_ segue:UIStoryboardSegue) {}
}

private enum ForceCategory {
    case soft, medium, hard
}
