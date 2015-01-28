//
//  GraphTabViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class GraphTabViewController : UITabBarController {
    private let connectionManager:WaxConnectionManager
    internal let dataProcessor:WaxProcessor
    
    required init(coder aDecoder: NSCoder)
    {
        dataProcessor = WaxProcessor(limit: 100)
        connectionManager = WaxConnectionManager(dataProcessor: dataProcessor)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}