//
//  FreeForceEvalVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 08/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit

class FreeForceEvalVC: EvaluationVC {
    fileprivate var stage:Int
    fileprivate var evalCount:Int
    fileprivate var attemptCount:Int!
    fileprivate var reqTouchForce:UInt32!
    
    fileprivate let scaleFactor:Float = 20.0
    
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
        self.performSegue(withIdentifier: "forceInstructions", sender: self)
        
        detector.subscribe(.allPress) { (data) -> Void in
            UIView.animate(withDuration: 1.0, animations: {
                self.forceImage.transform = CGAffineTransform(scaleX: CGFloat(data! * self.scaleFactor), y: CGFloat(data! * self.scaleFactor))
                }, completion: {
                    (value: Bool) in
                    UIView.animate(withDuration: 1.0, animations: {
                        self.forceImage.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    })
            })
            
            if (self.stage == 2) {
                self.logEvalData("\(self.participant),\(Date.timeIntervalSinceReferenceDate),\(Float(self.reqTouchForce) / self.scaleFactor),\(self.attemptCount + 1),\(data!)")
                if (self.attemptCount == 2) {
                    self.setNextView()
                    self.evalCount += 1
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
        UIView.animate(withDuration: 1.0, animations: {
            self.forceGuide.transform = CGAffineTransform(scaleX: CGFloat(self.reqTouchForce), y: CGFloat(self.reqTouchForce))
        })
    }
    
    func setNextView() {
        self.view.isUserInteractionEnabled = false
        instructionLbl.text = "Press next to advance to next stage."
    }
    
    func setForceView() {
        forceGuide.isHidden = false
        setRandomForce()
        instructionLbl.text = "Tap the screen with a force to match the blue circle."
        self.view.isUserInteractionEnabled = true
    }
    
    @IBAction func next(_ sender: AnyObject) {
        switch (stage) {
        case 1:
            setForceView()
            stage += 1
            break
        case 2:
            if (evalCount < 10) {
                setForceView()
            } else {
                nextBtn.isEnabled = false
                instructionLbl.text = "Evaluation Complete. Thank you."
                stage += 1
                logSensorData()
                evalVC.completeFreeForce(csv)
            }
            progressBar.setProgress(Float(evalCount) / 10.0, animated: true)
            break
        default:
            break
        }
    }
    
    @IBAction func unwindToFreeForceEval(_ segue:UIStoryboardSegue) {}
}
