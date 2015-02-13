//
//  ETDetectorViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 03/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class ETDetectorViewController: UIViewController {
    private let intDetector:InteractionDetector
    
    required init(coder aDecoder: NSCoder) {
        intDetector = InteractionDetector()
        
        super.init(coder: aDecoder)
    }
    
    func tappedView() {
        WaxProcessor.getProcessor().tapped()
    }
    
    func pinchedView() {
        WaxProcessor.getProcessor().pinched()
    }
    
    func rotatedView() {
        WaxProcessor.getProcessor().rotated()
    }
    
    func swipedView() {
        WaxProcessor.getProcessor().swiped()
    }
    
    func pannedView() {
        WaxProcessor.getProcessor().panned()
    }
    
    func edgePanView() {
        WaxProcessor.getProcessor().edgePan()
    }
    
    func longPressView() {
        WaxProcessor.getProcessor().longPress()
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tappedView"))
        self.view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "pinchedView"))
        self.view.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: "rotatedView"))
        self.view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: "swipedView"))
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "pannedView"))
        self.view.addGestureRecognizer(UIScreenEdgePanGestureRecognizer(target: self, action: "edgePanView"))
        self.view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "longPressView"))
        self.view.userInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}