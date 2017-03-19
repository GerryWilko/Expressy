//
//  GyroGraphVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation
import CorePlot

class GyroGraphVC: UIViewController {
    fileprivate let gyroGraphBuilder:GraphBuilder
    
    required init?(coder aDecoder: NSCoder) {
        gyroGraphBuilder = GraphBuilder(title: "Gyroscope", type: .gyroscope, dataCache: SensorProcessor.dataCache)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        let gyroGraphView = self.view as! CPTGraphHostingView
        gyroGraphBuilder.initLoad(gyroGraphView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        gyroGraphBuilder.resume()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        gyroGraphBuilder.pause()
    }
}
