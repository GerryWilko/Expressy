//
//  AccGraphVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class AccGraphVC: UIViewController {
    private let accGraphBuilder:GraphBuilder
    
    required init(coder aDecoder: NSCoder) {
        accGraphBuilder = GraphBuilder(title: "Accelerometer", type: .Accelerometer, dataCache: SensorProcessor.dataCache)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        let accGraphView = self.view as! CPTGraphHostingView
        accGraphBuilder.initLoad(accGraphView)
    }
    
    override func viewDidAppear(animated: Bool) {
        accGraphBuilder.resume()
    }
    
    override func viewDidDisappear(animated: Bool) {
        accGraphBuilder.pause()
    }
}