//
//  ForceViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 28/01/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class ForceViewController: UIViewController {
    private let forceDtc:ForceDetector
    
    required init(coder aDecoder: NSCoder) {
        forceDtc = ForceDetector(accCache: WaxProcessor.getProcessor().accCache)
        
        super.init(coder: aDecoder)
    }
    
    func tappedView() {
        let tapAlert = UIAlertController(title: "Tapped", message: String(format:"%f", forceDtc.getForce()), preferredStyle: UIAlertControllerStyle.Alert)
        tapAlert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
        self.presentViewController(tapAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tappedView"))
        self.view.userInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}