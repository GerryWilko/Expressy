//
//  AccViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class AccViewController: UIViewController {
    @IBOutlet weak var accGraphView:CPTGraphHostingView!
    
    let accGraphBuilder:GraphBuilder
    
    required init(coder aDecoder: NSCoder)
    {
        accGraphBuilder = GraphBuilder(title: "Accelerometer", live: GraphTabViewController.getLive())
        
        super.init(coder: aDecoder)
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let processor = WaxProcessor.getProcessor()
        
        accGraphBuilder.initLoad(accGraphView, dataCache: processor.accCache, infoCache: processor.infoCache)
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