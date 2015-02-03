//
//  MagViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class MagViewController: UIViewController {
    @IBOutlet weak var magGraphView:CPTGraphHostingView!
    
    let magGraphBuilder:GraphBuilder
    
    required init(coder aDecoder: NSCoder)
    {
        magGraphBuilder = GraphBuilder(title: "Magnetometer")
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabController = self.tabBarController as GraphTabViewController
        
        magGraphBuilder.initLoad(magGraphView, dataCache: WaxProcessor.getProcessor().magCache)
    }
    
    override func viewDidAppear(animated: Bool) {
        magGraphBuilder.resume()
    }
    
    override func viewDidDisappear(animated: Bool) {
        magGraphBuilder.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}