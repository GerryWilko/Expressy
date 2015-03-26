//
//  AccGraphVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class AccGraphVC: UIViewController {
    let accGraphBuilder:GraphBuilder
    
    required init(coder aDecoder: NSCoder)
    {
        accGraphBuilder = GraphBuilder(title: "Accelerometer", type: .Accelerometer)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let processor = WaxProcessor.getProcessor()
        let accGraphView = self.view as! CPTGraphHostingView
        
        accGraphBuilder.initLoad(accGraphView, dataCache: processor.dataCache)
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