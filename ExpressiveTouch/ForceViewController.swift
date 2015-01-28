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
    internal let dataProcessor:WaxProcessor
    private let connectionManager:WaxConnectionManager
    
    required init(coder aDecoder: NSCoder) {
        dataProcessor = WaxProcessor(limit: 100)
        connectionManager = WaxConnectionManager(dataProcessor: dataProcessor)
        
        forceDtc = ForceDetector(accCache: dataProcessor.accCache)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tappedView"))
        self.view.userInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedView() {
        let tapAlert = UIAlertController(title: "Tapped", message: String(format:"%f", forceDtc.getForce()), preferredStyle: UIAlertControllerStyle.Alert)
        tapAlert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
        self.presentViewController(tapAlert, animated: true, completion: nil)
    }
}