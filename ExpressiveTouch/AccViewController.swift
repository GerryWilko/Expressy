//
//  AccViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class AccViewController: UIViewController {
    @IBOutlet weak var accGraphView: CPTGraphHostingView!
    
    let accGraphBuilder:GraphBuilder
    
    required init(coder aDecoder: NSCoder)
    {
        accGraphBuilder = GraphBuilder(title: "Accelerometer")
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabController = self.tabBarController as GraphTabViewController
        
        accGraphBuilder.initLoad(accGraphView, dataCache: tabController.dataProcessor.accCache)
    }
    
    override func viewDidAppear(animated: Bool) {
        accGraphBuilder.resume()
    }
    
    override func viewDidDisappear(animated: Bool) {
        accGraphBuilder.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}