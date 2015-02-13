//
//  GraphTabViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

var liveData = true

class GraphTabViewController : UITabBarController {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func setLive(live:Bool) {
        liveData = live
    }
    
    class func getLive() -> Bool {
        return liveData
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(animated: Bool) {
        GraphTabViewController.setLive(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}