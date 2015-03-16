//
//  MagViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class MagViewController: UIViewController {
    let magGraphBuilder:GraphBuilder
    
    @IBOutlet weak var magGraphView:CPTGraphHostingView!
    
    required init(coder aDecoder: NSCoder)
    {
        magGraphBuilder = GraphBuilder(title: "Magnetometer", type: .Magnetometer)
        
        super.init(coder: aDecoder)
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let processor = WaxProcessor.getProcessor()
        
        magGraphBuilder.initLoad(magGraphView, dataCache: processor.dataCache)
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