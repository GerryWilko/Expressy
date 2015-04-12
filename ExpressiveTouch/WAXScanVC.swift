//
//  WAXScanVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 30/01/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import CoreBluetooth

var deviceList = NSMutableOrderedSet()
var currentTableView:UITableView!

class WAXScanVC: UITableViewController {
    required init(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentTableView = self.tableView
        WaxConnectionManager.getConnectionManager().scan()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        WaxConnectionManager.getConnectionManager().stop()
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
        return deviceList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let peripheral = deviceList[indexPath.row] as! CBPeripheral
        let cell = UITableViewCell()
        
        cell.textLabel!.text = peripheral.name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let peripheral = deviceList[indexPath.row] as! CBPeripheral
        WaxConnectionManager.getConnectionManager().connectPeripheral(peripheral)
        cancel(self)
    }
}