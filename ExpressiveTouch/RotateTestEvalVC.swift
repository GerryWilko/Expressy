//
//  RotateTestEvalVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 08/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class RotateTestEvalVC: UIViewController {
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var placeholderImage: UIImageView!
    @IBOutlet weak var rotateImage: UIImageView!
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var progressWheel: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        self.performSegueWithIdentifier("rotateTestInstructions", sender: self)
    }
    
    @IBAction func next(sender: AnyObject) {
    }
}