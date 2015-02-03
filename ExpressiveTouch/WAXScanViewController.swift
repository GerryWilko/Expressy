//
//  WAXScanViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 30/01/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import CoreBluetooth

var deviceList = [CBPeripheral]()

class WAXScanViewController: UITableViewController {
    var timer:NSTimer
    
    required init(coder aDecoder:NSCoder) {
        timer = NSTimer()
            
        super.init(coder: aDecoder)
        
        WaxConnectionManager.getConnectionManager().scan()
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self.tableView, selector: "reloadData", userInfo: nil, repeats: true)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        timer.invalidate()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    class func addDevice(device:CBPeripheral) {
        deviceList.append(device)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let candy = deviceList[indexPath.row]
        
        cell.textLabel!.text = candy.name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}