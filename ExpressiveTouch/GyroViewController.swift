//
//  GyroViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class GyroViewController: UIViewController {
    let gyroGraphBuilder:GraphBuilder
    
    @IBOutlet weak var gyroGraphView:CPTGraphHostingView!
    
    required init(coder aDecoder: NSCoder)
    {        
        gyroGraphBuilder = GraphBuilder(title: "Gyroscope", type: .Gyroscope)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let processor = WaxProcessor.getProcessor()
        
        gyroGraphBuilder.initLoad(gyroGraphView, dataCache: processor.dataCache)
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