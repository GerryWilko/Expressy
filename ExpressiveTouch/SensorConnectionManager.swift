//
//  SensorConnectionManager.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation
import CoreBluetooth

var connectionManager:SensorConnectionManager!

class SensorConnectionManager: NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate, MSBClientManagerDelegate
{
    private var cManager = CBCentralManager()
    private var peripheralManager = CBPeripheralManager()
    private var ready:Bool
    
    private let dataProcessor:SensorProcessor
    private let msbClient:MSBClient
    
    /// Initialises a new connection manager to handle Bluetooth connection to sensor.
    /// - returns: New SensorConnectionManager instance.
    init(dataProcessor:SensorProcessor) {
        assert(connectionManager == nil)
        
        self.dataProcessor = dataProcessor
        ready = false
        
        self.msbClient = MSBClient()
        
        super.init()
        
        cManager = CBCentralManager(delegate: self, queue:nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        MSBClientManager.sharedManager().delegate = self
        
        connectionManager = self
    }
    
    /// Function to retrieve instance of SensorConnectionManager (currently required due to lack of static variable support in Swift).
    /// - returns: Instance of SensorConnectionManager.
    class func getConnectionManager() -> SensorConnectionManager { return connectionManager }
    
    /// Function to initiate Bluetooth scan for sensors.
    /// - returns: Denotes wether a scan occured.
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
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch cManager.state {
        case .PoweredOff:
            print("CoreBluetooth BLE hardware is powered off")
            ready = false
            break
        case .PoweredOn:
            print("CoreBluetooth BLE hardware is powered on and ready")
            ready = true
            break
        case .Resetting:
            print("CoreBluetooth BLE hardware is resetting")
            ready = false
            break
        case .Unauthorized:
            print("CoreBluetooth BLE state is unauthorized")
            ready = false
            break
        case .Unknown:
            print("CoreBluetooth BLE state is unknown")
            ready = false
            break
        case .Unsupported:
            print("CoreBluetooth BLE hardware is unsupported on this platform")
            ready = false
            break
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print(peripheral.name);
        
        SensorScanVC.addDevice(peripheral)
    }
    
    /// Function to connect to specfied peripheral.
    /// - parameter peripheral: Peripheral to connect to.
    func connectPeripheral(peripheral: CBPeripheral) {
        cManager.connectPeripheral(peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("FAILED TO CONNECT \(error)")
        
        let conFailedAlert = UIAlertController(title: "Connection Failed", message: "Failed to connect to peripheral.", preferredStyle: UIAlertControllerStyle.Alert)
        conFailedAlert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(conFailedAlert, animated: true, completion: nil)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        switch peripheralManager.state {
            
        case .PoweredOff:
            print("Peripheral - CoreBluetooth BLE hardware is powered off")
            break
            
        case .PoweredOn:
            print("Peripheral - CoreBluetooth BLE hardware is powered on and ready")
            break
            
        case .Resetting:
            print("Peripheral - CoreBluetooth BLE hardware is resetting")
            break
            
        case .Unauthorized:
            print("Peripheral - CoreBluetooth BLE state is unauthorized")
            break
            
        case .Unknown:
            print("Peripheral - CoreBluetooth BLE state is unknown")
            break
            
        case .Unsupported:
            print("Peripheral - CoreBluetooth BLE hardware is unsupported on this platform")
            break
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        let serviceUDID = CBUUID(string: "00000000-0008-A8BA-E311-F48C90364D99")
        
        var serviceList = peripheral.services!.filter{ $0.UUID == serviceUDID }
        
        if (serviceList.count > 0) {
            peripheral.discoverCharacteristics(nil, forService: serviceList[0])
        } else {
            let conFailedAlert = UIAlertController(title: "Connection Failed", message: "Selected sensor does not have the required services.", preferredStyle: UIAlertControllerStyle.Alert)
            conFailedAlert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(conFailedAlert, animated: true, completion: nil)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        let notifyUDID = CBUUID(string: "00000002-0008-A8BA-E311-F48C90364D99")
        let writeUDID = CBUUID(string: "00000001-0008-A8BA-E311-F48C90364D99")
        
        let streamMessage = NSData(bytes: [1] as [UInt8], length: 1)
        
        if let notifyCharac = service.characteristics?.filter({ $0.UUID == notifyUDID }).first {
            peripheral.setNotifyValue(true, forCharacteristic: notifyCharac)
        }
        
        if let writeCharac = service.characteristics?.filter({ $0.UUID == writeUDID }).first {
            peripheral.writeValue(streamMessage, forCharacteristic: writeCharac, type: CBCharacteristicWriteType.WithoutResponse)
        }
        
        let conAlert = UIAlertController(title: "Connection Successful", message: "Sensor connected and data now being streamed.", preferredStyle: UIAlertControllerStyle.Alert)
        conAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(conAlert, animated: true, completion: nil)
        let navController = UIApplication.sharedApplication().keyWindow?.rootViewController as! UINavigationController
        let menu = navController.topViewController as! UITableViewController
        menu.tableView.userInteractionEnabled = true
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic,
        error: NSError?) {
        dataProcessor.updateCache(characteristic.value!)
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if(characteristic.isNotifying)
        {
            peripheral.readValueForCharacteristic(characteristic);
        }
    }
    
    func clientManager(clientManager: MSBClientManager!, clientDidConnect client: MSBClient!) {
        
    }
    
    func clientManager(clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
        
    }
    
    func clientManager(clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: NSError!) {
        
    }
}