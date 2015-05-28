//
//  MagGraphVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class MagGraphVC: UIViewController {
    private let magGraphBuilder:GraphBuilder
    
    required init(coder aDecoder: NSCoder) {
        magGraphBuilder = GraphBuilder(title: "Magnetometer", type: .Magnetometer, dataCache: SensorProcessor.getProcessor().dataCache)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        let magGraphView = self.view as! CPTGraphHostingView
        magGraphBuilder.initLoad(magGraphView)
    }
    
    override func viewDidAppear(animated: Bool) {
        magGraphBuilder.resume()
    }
    
    override func viewDidDisappear(animated: Bool) {
        magGraphBuilder.pause()
    }
}