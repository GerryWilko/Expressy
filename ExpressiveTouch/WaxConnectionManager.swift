//
//  WaxConnectionManager.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation
import CoreBluetooth

class WaxConnectionManager : NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    private var cManager = CBCentralManager()
    private var peripheralManager = CBPeripheralManager()
    private var discoveredPeripheral:CBPeripheral?
    
    private var dataProcessor:WaxProcessor
    
    private let deviceName:String = "WAX9-ABAB";
    
    init(dataProcessor:WaxProcessor) {
        self.dataProcessor = dataProcessor;
        
        super.init()
        
        cManager = CBCentralManager(delegate: self, queue:nil)
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        scan()
    }
    
    func scan() {
        cManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch cManager.state {
            
        case .PoweredOff:
            println("CoreBluetooth BLE hardware is powered off")
            break
        case .PoweredOn:
            println("CoreBluetooth BLE hardware is powered on and ready")
            self.scan()
            break
        case .Resetting:
            println("CoreBluetooth BLE hardware is resetting")
            break
        case .Unauthorized:
            println("CoreBluetooth BLE state is unauthorized")
            break
        case .Unknown:
            println("CoreBluetooth BLE state is unknown")
            break
        case .Unsupported:
            println("CoreBluetooth BLE hardware is unsupported on this platform")
            break
        default:
            break
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        println(peripheral.name);
        
        if (peripheral.name != nil && peripheral.name == deviceName) {
            
            central.connectPeripheral(peripheral, options: nil)
            
            self.discoveredPeripheral = peripheral
            
            println("PERIPHERAL NAME: \(peripheral.name)\n AdvertisementData: \(advertisementData)\n RSSI: \(RSSI)\n")
            
            println("UUID DESCRIPTION: \(peripheral.identifier.UUIDString)\n")
            
            println("IDENTIFIER: \(peripheral.identifier)\n")
            
            cManager.stopScan()
        }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
        println("Connected to peripheral")
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("FAILED TO CONNECT \(error)")
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
        if (error == nil) {
            println("ERROR: \(error)")
        }
        
        var serviceUDID = CBUUID(string: "00000000-0008-A8BA-E311-F48C90364D99")
        
        var serviceList = peripheral.services.filter{($0 as CBService).UUID == serviceUDID }
        
        if (serviceList.count > 0) {
            peripheral.discoverCharacteristics(nil, forService: serviceList[0] as CBService)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!)
    {
        var writeUDID = CBUUID(string: "00000001-0008-A8BA-E311-F48C90364D99")
        var notifyUDID = CBUUID(string: "00000002-0008-A8BA-E311-F48C90364D99")
        
        var streamMessage = NSData(bytes: [1] as [Byte], length: 1)
        
        peripheral.setNotifyValue(true, forCharacteristic: service.characteristics[2] as CBCharacteristic)
        
        peripheral.writeValue(streamMessage, forCharacteristic: service.characteristics[1] as CBCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!,
        error: NSError!) {
            println("\nCharacteristic \(characteristic.description) isNotifying: \(characteristic.isNotifying)\n")
            
            dataProcessor.updateCache(characteristic.value)
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if( characteristic.isNotifying )
        {
            peripheral.readValueForCharacteristic(characteristic);
        }
    }
}