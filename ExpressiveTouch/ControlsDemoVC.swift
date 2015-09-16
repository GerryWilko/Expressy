//
//  ControlsDemoVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 22/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import MDRadialProgress

class ControlsDemoVC: UIViewController {
    private var touchImageTransform:CGAffineTransform!
    private var touchProgress:UInt
    
    private var rotationRecognizer:UIRotationGestureRecognizer!
    private var rollRecognizer:EXTRollGestureRecognizer!
    
    @IBOutlet weak var progressView: MDRadialProgressView!
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        touchProgress = 0
        
        super.init(coder: aDecoder)
        
        rotationRecognizer = UIRotationGestureRecognizer(target: self, action: Selector("imageRotated:"))
        rollRecognizer = EXTRollGestureRecognizer(target: self, action: Selector("imageEXTRoll:"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.addGestureRecognizer(EXTRollGestureRecognizer(target: self, action: Selector("progressRoll:")))
        progressView.progressCounter = 0
        progressView.progressTotal = UInt(100)
        
        touchImageTransform = imageView.transform
        
        imageView.addGestureRecognizer(rollRecognizer)
    }
    
    func progressRoll(recognizer:EXTRollGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            touchProgress = progressView.progressCounter
        case .Changed:
            var newValue = Int(touchProgress) + Int(recognizer.currentRoll)
            
            if newValue > 100 {
                newValue = 100
            } else if newValue < 0 {
                newValue = 0
            }
            
            progressView.progressCounter = UInt(newValue)
        default:
            break
        }
    }
    
    @IBAction func imageEXTSwitch(sender: UISwitch) {
        if sender.on {
            imageView.removeGestureRecognizer(rotationRecognizer)
            imageView.addGestureRecognizer(rollRecognizer)
        } else {
            imageView.removeGestureRecognizer(rollRecognizer)
            imageView.addGestureRecognizer(rotationRecognizer)
        }
    }
    
    func imageRotated(recognizer:UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            touchImageTransform = imageView.transform
        case .Changed:
            imageView.transform = CGAffineTransformRotate(touchImageTransform, recognizer.rotation)
        default:
            break
        }
    }
    
    func imageEXTRoll(recognizer:EXTRollGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            touchImageTransform = imageView.transform
        case .Changed:
            imageView.transform = CGAffineTransformRotate(touchImageTransform, CGFloat(recognizer.currentRoll) * CGFloat(M_PI / 180))
        default:
            break
        }
    }
}