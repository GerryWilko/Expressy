//
//  PaintingDemoVC.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 03/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation

class PaintingDemoVC: UIViewController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func clear(sender: AnyObject) {
        let paintView = self.view as! DAScratchPadView
        paintView.clearToColor(UIColor.whiteColor())
    }
}