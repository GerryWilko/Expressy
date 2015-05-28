//
//  GyroGraphVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class GyroGraphVC: UIViewController {
    private let gyroGraphBuilder:GraphBuilder
    
    required init(coder aDecoder: NSCoder) {
        gyroGraphBuilder = GraphBuilder(title: "Gyroscope", type: .Gyroscope, dataCache: SensorProcessor.getProcessor().dataCache)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        let gyroGraphView = self.view as! CPTGraphHostingView
        gyroGraphBuilder.initLoad(gyroGraphView)
    }
    
    override func viewDidAppear(animated: Bool) {
        gyroGraphBuilder.resume()
    }
    
    override func viewDidDisappear(animated: Bool) {
        gyroGraphBuilder.pause()
    }
}