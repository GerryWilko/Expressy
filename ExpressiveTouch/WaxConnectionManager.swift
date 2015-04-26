//
//  WaxConnectionManager.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation
import CoreBluetooth

var connectionManager:WaxConnectionManager!

class WaxConnectionManager : NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate
{
    private var cManager = CBCentralManager()
    private var peripheralManager = CBPeripheralManager()
    private var dataProcessor:WaxProcessor!
    private var ready:Bool
    
    /// Initialises a new connection manager to handle Bluetooth connection to sensor.
    /// :returns: New WaxConnectionManager instance.
    init(dataProcessor:WaxProcessor) {
        assert(connectionManager == nil)
        
        self.dataProcessor = dataProcessor
        ready = false
        
        super.init()
        
        cManager = CBCentralManager(delegate: self, queue:nil)
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        connectionManager = self
    }
    
    /// Function to retrieve instance of WaxConnectionManager (currently required due to lack of static variable support in Swift).
    /// :returns: Instance of WaxConnectionManager.
    class func getConnectionManager() -> WaxConnectionManager { return connectionManager }
    
    /// Function to initiate Bluetooth scan for sensors.
    /// :returns: Denotes wether a scan occured.
    func scan() -> Bool {
        if (ready) {
            cManager.scanForPeripheralsWithServices(nil, options: nil)
        }
        
        return ready
    }
    
    /// Function to stop scanning for sensors.
    func stop() {
        cManager.stopScan()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch cManager.state {
        case .PoweredOff:
            println("CoreBluetooth BLE hardware is powered off")
            ready = false
            break
        case .PoweredOn:
            println("CoreBluetooth BLE hardware is powered on and ready")
            ready = true
            break
        case .Resetting:
            println("CoreBluetooth BLE hardware is resetting")
            ready = false
            break
        case .Unauthorized:
            println("CoreBluetooth BLE state is unauthorized")
            ready = false
            break
        case .Unknown:
            println("CoreBluetooth BLE state is unknown")
            ready = false
            break
        case .Unsupported:
            println("CoreBluetooth BLE hardware is unsupported on this platform")
            ready = false
            break
        default:
            ready = false
            break
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println(peripheral.name);
        
        WAXScanVC.addDevice(peripheral)
    }
    
    /// Function to connect to specfied peripheral.
    /// :param: peripheral Peripheral to connect to.
    func connectPeripheral(peripheral: CBPeripheral) {
        cManager.connectPeripheral(peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("FAILED TO CONNECT \(error)")
        
        let conFailedAlert = UIAlertController(title: "Connection Failed", message: "Failed to connect to peripheral.", preferredStyle: UIAlertControllerStyle.Alert)
        conFailedAlert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(conFailedAlert, animated: true, completion: nil)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        switch peripheralManager.state {
            
        case .PoweredOff:
            println("Peripheral - CoreBluetooth BLE hardware is powered off")
            break
            
        case .PoweredOn:
            println("Peripheral - CoreBluetooth BLE hardware is powered on and ready")
            break
            
        case .Resetting:
            println("Peripheral - CoreBluetooth BLE hardware is resetting")
            break
            
        case .Unauthorized:
            println("Peripheral - CoreBluetooth BLE state is unauthorized")
            break
            
        case .Unknown:
            println("Peripheral - CoreBluetooth BLE state is unknown")
            break
            
        case .Unsupported:
            println("Peripheral - CoreBluetooth BLE hardware is unsupported on this platform")
            break
        default:
            break
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        var serviceUDID = CBUUID(string: "00000000-0008-A8BA-E311-F48C90364D99")
        
        var serviceList = peripheral.services.filter{($0 as! CBService).UUID == serviceUDID }
        
        if (serviceList.count > 0) {
            peripheral.discoverCharacteristics(nil, forService: serviceList[0] as! CBService)
        } else {
            let conFailedAlert = UIAlertController(title: "Connection Failed", message: "Selected sensor does not have the required services.", preferredStyle: UIAlertControllerStyle.Alert)
            conFailedAlert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(conFailedAlert, animated: true, completion: nil)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!)
    {
        var writeUDID = CBUUID(string: "00000001-0008-A8BA-E311-F48C90364D99")
        var notifyUDID = CBUUID(string: "00000002-0008-A8BA-E311-F48C90364D99")
        
        var streamMessage = NSData(bytes: [1] as [UInt8], length: 1)
        
        peripheral.setNotifyValue(true, forCharacteristic: service.characteristics[2] as! CBCharacteristic)
        
        peripheral.writeValue(streamMessage, forCharacteristic: service.characteristics[1] as! CBCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
        
        let conAlert = UIAlertController(title: "Connection Successful", message: "WAX sensor connected and data now being streamed.", preferredStyle: UIAlertControllerStyle.Alert)
        conAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(conAlert, animated: true, completion: nil)
        let navController = UIApplication.sharedApplication().keyWindow?.rootViewController as! UINavigationController
        let menu = navController.topViewController as! UITableViewController
        menu.tableView.userInteractionEnabled = true
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!,
        error: NSError!) {
        dataProcessor.updateCache(characteristic.value)
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if(characteristic.isNotifying)
        {
            peripheral.readValueForCharacteristic(characteristic);
        }
    }
}