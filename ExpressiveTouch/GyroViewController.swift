//
//  GyroViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class GyroViewController: UIViewController {
    @IBOutlet weak var gyroGraphView:CPTGraphHostingView!
    
    let gyroGraphBuilder:GraphBuilder
    
    required init(coder aDecoder: NSCoder)
    {        
        gyroGraphBuilder = GraphBuilder(title: "Gyroscope", live: GraphTabViewController.getLive())
        
        super.init(coder: aDecoder)
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let processor = WaxProcessor.getProcessor()
        
        gyroGraphBuilder.initLoad(gyroGraphView, dataCache: processor.gyroCache, infoCache: processor.infoCache)
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