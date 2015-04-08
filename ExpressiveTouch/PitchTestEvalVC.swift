//
//  PitchTestEvalVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 08/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class PitchTestEvalVC: UIViewController {
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var pitchBar: UIProgressView!
    @IBOutlet weak var intructionLbl: UILabel!
    
    override func viewDidLoad() {
        progressBar.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI / 2))
        self.performSegueWithIdentifier("pitchTestInstructions", sender: self)
    }
    
    @IBAction func next(sender: AnyObject) {
    }
}