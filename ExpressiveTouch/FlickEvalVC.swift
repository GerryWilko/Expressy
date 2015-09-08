//
//  FlickEvalVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 11/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class FlickEvalVC: EvaluationVC {
    private var runStack:[Flick]!
    private var current:Flick!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCSV("flick", headerLine: "Participant ID,Time,Requested,Flick Force")
        runStack = buildRunStack()
        self.performSegueWithIdentifier("flickTestInstructions", sender: self)
        detector.subscribe(EventType.Flick, callback: flickedCallback)
        detector.subscribe(EventType.NoFlick, callback: flickedCallback)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        setFlickView()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        setWaitView()
    }
    
    private func buildRunStack() -> [Flick] {
        var runStack = [Flick]()
        var flick = 5, noFlick = 5
        
        while (flick != 0 || noFlick != 0) {
            let num = Int(arc4random_uniform(2))
            
            if (num == 0 && flick != 0) {
                runStack.append(Flick.Flick)
                flick--
            } else if (num == 1 && noFlick != 0) {
                runStack.append(Flick.NoFlick)
                noFlick--
            }
        }
        
        return runStack
    }
    
    private func flickedCallback(data:Float?) {
        let time = NSDate.timeIntervalSinceReferenceDate()
        let currentString = current == Flick.Flick ? "Flick" : "No Flick"
        logEvalData("\(participant),\(time),\(currentString),\(data!)")
        setNextView()
    }
    
    private func setWaitView() {
        instructionLbl.text = "Please wait..."
        instructionLbl.textColor = UIColor.blackColor()
        self.view.userInteractionEnabled = false
    }
    
    private func setNextView() {
        instructionLbl.text = "Press next to advance to the next stage."
        instructionLbl.textColor = UIColor.blackColor()
    }
    
    private func setFlickView() {
        current = runStack[0]
        runStack.removeAtIndex(0)
        
        switch (current!) {
        case .Flick:
            instructionLbl.text = "Flick off the screen."
            instructionLbl.textColor = UIColor.greenColor()
            break
        case .NoFlick:
            instructionLbl.text = "Lift off the screen, without flicking."
            instructionLbl.textColor = UIColor.redColor()
            break
        }
    }
    
    @IBAction func next(sender: AnyObject) {
        if runStack.isEmpty {
            nextBtn.enabled = false
            instructionLbl.text = "Evaluation complete. Thank you."
            instructionLbl.textColor = UIColor.blackColor()
            logSensorData()
            evalVC.completeFlick(csv)
        } else {
            instructionLbl.text = "Press and hold."
            instructionLbl.textColor = UIColor.blackColor()
            self.view.userInteractionEnabled = true
        }
        
        progressBar.setProgress(Float(Float(10 - runStack.count) / 10.0), animated: true)
    }
    
    @IBAction func unwindToFlickEval(segue:UIStoryboardSegue) {}
}

private enum Flick {
    case Flick, NoFlick
}