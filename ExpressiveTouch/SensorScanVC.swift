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
    
    required init(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SensorScanVC.currentTableView = self.tableView
        SensorConnectionManager.getConnectionManager().scan()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        SensorConnectionManager.getConnectionManager().stop()
        self.dismissViewControllerAnimated(true, completion: nil)
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
        let peripheral = SensorScanVC.deviceList[indexPath.row] as! CBPeripheral
        SensorConnectionManager.getConnectionManager().connectPeripheral(peripheral)
        
        cancel(self)
    }
}