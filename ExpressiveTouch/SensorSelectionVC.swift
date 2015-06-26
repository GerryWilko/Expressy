//
//  SensorSelectionVC.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 26/06/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import WatchConnectivity

class SensorSelectionVC: UIViewController {
    @IBOutlet weak var appleWatchBtn: UIButton!
    @IBOutlet weak var msbBtn: UIButton!
    @IBOutlet weak var otherBluetoothBtn: UIButton!
    
    override func viewDidLoad() {
        appleWatchBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        msbBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        otherBluetoothBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        
        appleWatchBtn.enabled = WCSession.defaultSession().paired
        msbBtn.enabled = !MSBClientManager.sharedManager().attachedClients().isEmpty
    }
    
    @IBAction func cancelBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func appleWatchPressed(sender: AnyObject) {
        
    }
    
    @IBAction func msbPressed(sender: AnyObject) {
        SensorConnectionManager.getConnectionManager().connectMSB()
    }
}