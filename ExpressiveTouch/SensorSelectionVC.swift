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
        if #available(iOS 9.0, *) {
            appleWatchBtn.enabled = WCSession.defaultSession().paired
        }
        msbBtn.enabled = !MSBClientManager.sharedManager().attachedClients().isEmpty
    }
    
    @IBAction func appleWatchPressed(sender: AnyObject) {
        
    }
    
    @IBAction func msbPressed(sender: AnyObject) {
        SensorConnectionManager.getConnectionManager().connectMSB()
    }
}