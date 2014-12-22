//
//  GyroViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class GyroViewController: UIViewController {
    @IBOutlet weak var gyroGraphView: CPTGraphHostingView!
    
    let gyroGraphBuilder:GraphBuilder
    
    required init(coder aDecoder: NSCoder)
    {        
        gyroGraphBuilder = GraphBuilder(title: "Gyroscope")
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabController = self.tabBarController as GraphTabViewController
        
        gyroGraphBuilder.initLoad(gyroGraphView, dataCache: tabController.dataProcessor.gyroCache)
    }
    
    override func viewDidAppear(animated: Bool) {
        gyroGraphBuilder.resume()
    }
    
    override func viewDidDisappear(animated: Bool) {
        gyroGraphBuilder.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}