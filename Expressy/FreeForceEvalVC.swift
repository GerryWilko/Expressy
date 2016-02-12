//
//  FreeForceEvalVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 08/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class FreeForceEvalVC: EvaluationVC {
    private var stage:Int
    private var evalCount:Int
    private var attemptCount:Int!
    private var reqTouchForce:UInt32!
    
    private let scaleFactor:Float = 20.0
    
    @IBOutlet weak var forceImage: UIImageView!
    @IBOutlet weak var forceGuide: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        stage = 1
        evalCount = 0
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCSV("freeForce", headerLine: "Participant ID,Time,Requested Force,Attempt,Tapped Force")
        self.performSegueWithIdentifier("forceInstructions", sender: self)
        
        detector.subscribe(.AllPress) { (data) -> Void in
            UIView.animateWithDuration(1.0, animations: {
                self.forceImage.transform = CGAffineTransformMakeScale(CGFloat(data! * self.scaleFactor), CGFloat(data! * self.scaleFactor))
                }, completion: {
                    (value: Bool) in
                    UIView.animateWithDuration(1.0, animations: {
                        self.forceImage.transform = CGAffineTransformMakeScale(0.01, 0.01)
                    })
            })
            
            if (self.stage == 2) {
                self.logEvalData("\(self.participant),\(NSDate.timeIntervalSinceReferenceDate()),\(Float(self.reqTouchForce) / self.scaleFactor),\(self.attemptCount + 1),\(data!)")
                if (self.attemptCount == 2) {
                    self.setNextView()
                    self.evalCount++
                } else {
                    self.attemptCount = self.attemptCount + 1
                    self.instructionLbl.text = "Attempt: \(self.attemptCount! + 1)"
                }
            }
        }
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
                nextBtn.enabled = false
                instructionLbl.text = "Evaluation Complete. Thank you."
                stage++
                logSensorData()
                evalVC.completeFreeForce(csv)
            }
            progressBar.setProgress(Float(evalCount) / 10.0, animated: true)
            break
        default:
            break
        }
    }
    
    @IBAction func unwindToFreeForceEval(segue:UIStoryboardSegue) {}
}