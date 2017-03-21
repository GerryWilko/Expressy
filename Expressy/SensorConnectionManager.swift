//
//  SensorConnectionManager.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class SensorConnectionManager: NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate
{
    fileprivate static var connectionManager:SensorConnectionManager!
    
    fileprivate var cManager = CBCentralManager()
    fileprivate var peripheralManager = CBPeripheralManager()
    fileprivate var ready:Bool
    fileprivate var readyCallbacks:[() -> Void]
    fileprivate var connectionCallback:((Error?) -> Void)?
    
    /// Initialises a new connection manager to handle Bluetooth connection to sensor.
    /// - returns: New SensorConnectionManager instance.
    override init() {
        assert(SensorConnectionManager.connectionManager == nil)
        
        ready = false
        readyCallbacks = Array<() -> Void>()
        
        super.init()
        
        cManager = CBCentralManager(delegate: self, queue:nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        SensorConnectionManager.connectionManager = self
    }
    
    /// Function to retrieve instance of SensorConnectionManager.
    /// - returns: Instance of SensorConnectionManager.
    class func getConnectionManager() -> SensorConnectionManager {
        if connectionManager == nil {
            connectionManager = SensorConnectionManager()
        }
        
        return connectionManager
    }
    
    func subscribeReady(_ callback:@escaping () -> Void) {
        if (ready) {
            callback()
        } else {
            readyCallbacks.append(callback)
        }
    }
    
    
    func clearReadySubscriptions() {
        readyCallbacks.removeAll(keepingCapacity: false)
    }
    
    /// Function to initiate Bluetooth scan for sensors.
    /// - returns: Denotes wether a scan occured.
    func scan() -> Bool {
        if (ready) {
            cManager.scanForPeripherals(withServices: nil, options: nil)
        }
        
        return ready
    }
    
    /// Function to stop scanning for sensors.
    func stop() {
        cManager.stopScan()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch cManager.state {
        case .poweredOff:
            print("CoreBluetooth BLE hardware is powered off")
            ready = false
            break
        case .poweredOn:
            print("CoreBluetooth BLE hardware is powered on and ready")
            ready = true
            readyCallbacks.forEach({ (cb) -> () in
                cb()
            })
            break
        case .resetting:
            print("CoreBluetooth BLE hardware is resetting")
            ready = false
            break
        case .unauthorized:
            print("CoreBluetooth BLE state is unauthorized")
            ready = false
            break
        case .unknown:
            print("CoreBluetooth BLE state is unknown")
            ready = false
            break
        case .unsupported:
            print("CoreBluetooth BLE hardware is unsupported on this platform")
            ready = false
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name != nil) {
            SensorScanVC.addDevice(peripheral)
        }
    }
    
    /// Function to connect to specfied peripheral.
    /// - parameter peripheral: Peripheral to connect to.
    func connectPeripheral(_ peripheral: CBPeripheral, completedCallback:@escaping (Error?) -> Void) {
        connectionCallback = completedCallback
        cManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("FAILED TO CONNECT \(error)")
        
        connectionCallback?(error)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheralManager.state {
            
        case .poweredOff:
            print("Peripheral - CoreBluetooth BLE hardware is powered off")
            break
            
        case .poweredOn:
            print("Peripheral - CoreBluetooth BLE hardware is powered on and ready")
            break
            
        case .resetting:
            print("Peripheral - CoreBluetooth BLE hardware is resetting")
            break
            
        case .unauthorized:
            print("Peripheral - CoreBluetooth BLE state is unauthorized")
            break
            
        case .unknown:
            print("Peripheral - CoreBluetooth BLE state is unknown")
            break
            
        case .unsupported:
            print("Peripheral - CoreBluetooth BLE hardware is unsupported on this platform")
            break
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let serviceUDID = CBUUID(string: "00000000-0008-A8BA-E311-F48C90364D99")
        let sampleRateServiceUDID = CBUUID(string: "00000005-0008-A8BA-E311-F48C90364D99")
        
        var serviceList = peripheral.services!.filter{ $0.uuid == serviceUDID || $0.uuid == sampleRateServiceUDID }
        
        if (serviceList.count > 0) {
            peripheral.discoverCharacteristics(nil, for: serviceList[0])
        } else {
            
            connectionCallback?(NSError(domain: "bluetooth", code: 1, userInfo: ["message": "Selected sensor does not have the required services."]))
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let notifyUUID = CBUUID(string: "00000002-0008-A8BA-E311-F48C90364D99")
        let writeUUID = CBUUID(string: "00000001-0008-A8BA-E311-F48C90364D99")
        let sampleRateUUID = CBUUID(string: "0000000A-0008-A8BA-E311-F48C90364D99")
        
        if let sampleRateCharac = service.characteristics?.filter({$0.uuid == sampleRateUUID}).first {
            let sampleRateMessage = Data(bytes: [0x00, 0x32], count: 2)
            peripheral.writeValue(sampleRateMessage, for: sampleRateCharac, type: .withoutResponse)
        }
        
        if let notifyCharac = service.characteristics?.filter({ $0.uuid == notifyUUID }).first {
            peripheral.setNotifyValue(true, for: notifyCharac)
        }
        
        if let writeCharac = service.characteristics?.filter({ $0.uuid == writeUUID }).first {
            let streamMessage = Data(bytes: UnsafePointer<UInt8>([1] as [UInt8]), count: 1)
            peripheral.writeValue(streamMessage, for: writeCharac, type: .withoutResponse)
        }
        
        connectionCallback?(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?) {
        SensorProcessor.updateCache(characteristic.value!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if(characteristic.isNotifying)
        {
            peripheral.readValue(for: characteristic);
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let nav = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as! UINavigationController
        nav.popToRootViewController(animated: true)
        (nav.topViewController as! MenuVC).connectDeviceBtn.isEnabled = true
        
        let alert = UIAlertController(title: "Sensor Disconnected", message: "Connection to the sensor has been lost. You have been returned to the main menu.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        
        nav.topViewController!.present(alert, animated: true, completion: nil)
    }
}
