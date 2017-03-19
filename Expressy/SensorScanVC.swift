//
//  SensorScanVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 30/01/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class SensorScanVC: UITableViewController {
    static var deviceList:NSMutableOrderedSet = []
    fileprivate static var currentTableView:UITableView!
    
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
        refreshControl.addTarget(self, action: #selector(SensorScanVC.scanAgain(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        SensorConnectionManager.getConnectionManager().stop()
        dismiss(animated: true, completion: nil)
    }
    
    func scanAgain(_ refreshControl:UIRefreshControl) {
        SensorConnectionManager.getConnectionManager().scan()
        refreshControl.endRefreshing()
    }
    
    class func addDevice(_ device:CBPeripheral) {
        deviceList.add(device)
        reloadData()
    }
    
    class func reloadData() {
        currentTableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SensorScanVC.deviceList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let peripheral = SensorScanVC.deviceList[indexPath.row] as! CBPeripheral
        let cell = UITableViewCell()
        
        cell.textLabel!.text = peripheral.name
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SensorConnectionManager.getConnectionManager().stop()
        let peripheral = SensorScanVC.deviceList[indexPath.row] as! CBPeripheral
        SensorConnectionManager.getConnectionManager().connectPeripheral(peripheral, completedCallback: { (error) -> Void in
            var alert:UIAlertController
            
            if let e = error {
                if (!e.localizedDescription.isEmpty) {
                    alert = UIAlertController(title: "Connection Failed", message: e.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                } else {
                    alert = UIAlertController(title: "Connection Failed", message: "Unable to connect to sensor. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                }
            } else {
                alert = UIAlertController(title: "Connection Success", message: "Sensor is now connected and streaming.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action) -> Void in
                    self.performSegue(withIdentifier: "unwindToMenuSegue", sender: self)
                }))
            }
            
            self.present(alert, animated: true, completion: nil)
        })
    }
}
