//
//  SensorSelectionVC.swift
//  Expressy
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
        super.viewDidLoad()
        SensorConnectionManager.getConnectionManager().startAppleWatchSensorUpdates()
        appleWatchBtn.enabled = WCSession.defaultSession().paired
        msbBtn.enabled = !MSBClientManager.sharedManager().attachedClients().isEmpty
    }
    
    @IBAction func appleWatchPressed(sender: AnyObject) {
        let alert = UIAlertController(title: "Not currently available", message: "Unfortunately due to SDK restrictions Expressive Touch cannot work with an Apple Watch. We have support ready to go as soon as Apple open access to Gyroscope data.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func msbPressed(sender: AnyObject) {
        SensorConnectionManager.getConnectionManager().connectMSB()
    }
}