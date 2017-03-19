//
//  FlickEvalVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 11/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit

class FlickEvalVC: EvaluationVC {
    fileprivate var runStack:[Flick]!
    fileprivate var current:Flick!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCSV("flick", headerLine: "Participant ID,Time,Requested,Flick Force")
        runStack = buildRunStack()
        self.performSegue(withIdentifier: "flickTestInstructions", sender: self)
        detector.subscribe(.flick, callback: flickedCallback)
        detector.subscribe(.noFlick, callback: flickedCallback)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        setFlickView()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        setWaitView()
    }
    
    fileprivate func buildRunStack() -> [Flick] {
        var runStack = [Flick]()
        var flick = 5, noFlick = 5
        
        while (flick != 0 || noFlick != 0) {
            let num = Int(arc4random_uniform(2))
            
            if (num == 0 && flick != 0) {
                runStack.append(Flick.flick)
                flick -= 1
            } else if (num == 1 && noFlick != 0) {
                runStack.append(Flick.noFlick)
                noFlick -= 1
            }
        }
        
        return runStack
    }
    
    fileprivate func flickedCallback(_ data:Float?) {
        let time = Date.timeIntervalSinceReferenceDate
        let currentString = current == Flick.flick ? "Flick" : "No Flick"
        logEvalData("\(participant),\(time),\(currentString),\(data!)")
        setNextView()
    }
    
    fileprivate func setWaitView() {
        instructionLbl.text = "Please wait..."
        instructionLbl.textColor = UIColor.black
        self.view.isUserInteractionEnabled = false
    }
    
    fileprivate func setNextView() {
        instructionLbl.text = "Press next to advance to the next stage."
        instructionLbl.textColor = UIColor.black
    }
    
    fileprivate func setFlickView() {
        current = runStack[0]
        runStack.remove(at: 0)
        
        switch (current!) {
        case .flick:
            instructionLbl.text = "Flick off the screen."
            instructionLbl.textColor = UIColor.green
            break
        case .noFlick:
            instructionLbl.text = "Lift off the screen, without flicking."
            instructionLbl.textColor = UIColor.red
            break
        }
    }
    
    @IBAction func next(_ sender: AnyObject) {
        if runStack.isEmpty {
            nextBtn.isEnabled = false
            instructionLbl.text = "Evaluation complete. Thank you."
            instructionLbl.textColor = UIColor.black
            logSensorData()
            evalVC.completeFlick(csv)
        } else {
            instructionLbl.text = "Press and hold."
            instructionLbl.textColor = UIColor.black
            self.view.isUserInteractionEnabled = true
        }
        
        progressBar.setProgress(Float(Float(10 - runStack.count) / 10.0), animated: true)
    }
    
    @IBAction func unwindToFlickEval(_ segue:UIStoryboardSegue) {}
}

private enum Flick {
    case flick, noFlick
}
