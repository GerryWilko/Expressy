//
//  ETDetectorViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 03/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class ETDetectorViewController: UIViewController {
    @IBOutlet weak var interactionView: InteractionView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        interactionView.detector.stopDetection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}