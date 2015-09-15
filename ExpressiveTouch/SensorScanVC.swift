//
//  SensorScanVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 30/01/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import CoreBluetooth

class SensorScanVC: UITableViewController {
    static var deviceList:NSMutableOrderedSet = []
    private static var currentTableView:UITableView!
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SensorScanVC.currentTableView = self.tableView
        
        let conMan = SensorConnectionManager.getConnectionManager()
        conMan.clearReadySubscriptions()
        conMan.subscribeReady({
            conMan.scan()
        })
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: Selector("scanAgain:"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        SensorConnectionManager.getConnectionManager().stop()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func scanAgain(refreshControl:UIRefreshControl) {
        SensorConnectionManager.getConnectionManager().scan()
        refreshControl.endRefreshing()
    }
    
    class func addDevice(device:CBPeripheral) {
        deviceList.addObject(device)
        reloadData()
    }
    
    class func reloadData() {
        currentTableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SensorScanVC.deviceList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let peripheral = SensorScanVC.deviceList[indexPath.row] as! CBPeripheral
        let cell = UITableViewCell()
        
        cell.textLabel!.text = peripheral.name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        SensorConnectionManager.getConnectionManager().stop()
        let peripheral = SensorScanVC.deviceList[indexPath.row] as! CBPeripheral
        SensorConnectionManager.getConnectionManager().connectPeripheral(peripheral, completedCallback: { (error) -> Void in
            var alert:UIAlertController
            
            if let e = error {
                if (e.userInfo["message"] != nil) {
                    alert = UIAlertController(title: "Connection Failed", message: error!.userInfo["message"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                } else {
                    alert = UIAlertController(title: "Connection Failed", message: "Unable to connect to sensor. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                }
            } else {
                alert = UIAlertController(title: "Connection Success", message: "Sensor is now connected and streaming.", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
                    self.performSegueWithIdentifier("unwindToMenuSegue", sender: self)
                }))
            }
            
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
}