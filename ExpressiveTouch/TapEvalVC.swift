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
    private var runStack:[ForceCategory]!
    private var current:ForceCategory
    
    private let detector:InteractionDetector
    private let csv:CSVBuilder
    
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        detector.startDetection()
        csv = CSVBuilder(fileNames: ["tapForce.csv","tapData.csv"], headerLines: ["Requested Force,Tap Force", "Time,ax,ay,az,gx,gy,gz,mx,my,mz,gravx,gravy,gravz,yaw,pitch,roll"])
        current = ForceCategory.Soft
        super.init(coder: aDecoder)
        runStack = buildRunStack()
    }
    
    override func viewDidLoad() {
        self.performSegueWithIdentifier("tapForceInstructions", sender: self)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("tappedView")))
        WaxProcessor.getProcessor().dataCache.subscribe(dataCallback)
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
    
    func tappedView() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        let tapForce = detector.calculateTouchForce(NSDate.timeIntervalSinceReferenceDate())
        
        progressBar.setProgress(Float(Float(30 - runStack.count) / 30.0), animated: true)
        
        switch (current) {
        case .Soft:
            csv.appendRow("Soft,\(tapForce)", index: 0)
            break
        case .Medium:
            csv.appendRow("Medium,\(tapForce)", index: 0)
            break
        case .Hard:
            csv.appendRow("Hard,\(tapForce)", index: 0)
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
    
    func dataCallback(data:WaxData) {
        csv.appendRow(data.print(), index: 1)
    }
}

enum ForceCategory {
    case Soft, Medium, Hard
}