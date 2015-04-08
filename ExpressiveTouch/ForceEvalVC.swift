//
//  ForceEvalVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 08/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class ForceEvalVC: UIViewController {
    let detector:InteractionDetector
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var forceBar: UIProgressView!
    @IBOutlet weak var intructionLbl: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        detector.startDetection()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        forceBar.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI / 2.0))
        self.performSegueWithIdentifier("forceInstructions", sender: self)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let time = NSDate.timeIntervalSinceReferenceDate()
        detector.touchDown(time)
        let touchForce = detector.calculateTouchForce(time)
        var bar = touchForce / 30.0
        bar = bar > 1.0 ? 1.0 : bar
        forceBar.setProgress(bar, animated: true)
        println("force: \(touchForce), bar: \(touchForce / 30.0)")
    }
    
    @IBAction func next(sender: AnyObject) {
    }
}