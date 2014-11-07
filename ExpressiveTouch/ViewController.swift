//
//  ViewController.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 11/10/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore
import CoreData
import Foundation

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralManagerDelegate,CBPeripheralDelegate {
    @IBOutlet weak var scanForWAX9: UIButton!
    
    @IBOutlet weak var sensorData: UITextView!
    
    @IBAction func scanForWAX9(sender: AnyObject) {
        cManager.scanForPeripheralsWithServices(nil, options: nil)
        sensorData.text = "\nNow Scanning for PERIPHERALS!\n"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        cManager = CBCentralManager(delegate: self, queue:nil)
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Bluetooth Connection
    
    var cManager = CBCentralManager()
    var peripheralManager = CBPeripheralManager()
    
    var discoveredPeripheral:CBPeripheral?
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch cManager.state {
            
        case .PoweredOff:
            println("CoreBluetooth BLE hardware is powered off")
            self.sensorData.text = "CoreBluetooth BLE hardware is powered off\n"
            break
        case .PoweredOn:
            println("CoreBluetooth BLE hardware is powered on and ready")
            self.sensorData.text = "CoreBluetooth BLE hardware is powered on and ready\n"
            // We can now call scanForBeacons
            self.scanForWAX9(self)
            break
        case .Resetting:
            println("CoreBluetooth BLE hardware is resetting")
            self.sensorData.text = "CoreBluetooth BLE hardware is resetting\n"
            break
        case .Unauthorized:
            println("CoreBluetooth BLE state is unauthorized")
            self.sensorData.text = "CoreBluetooth BLE state is unauthorized\n"
            
            break
        case .Unknown:
            println("CoreBluetooth BLE state is unknown")
            self.sensorData.text = "CoreBluetooth BLE state is unknown\n"
            break
        case .Unsupported:
            println("CoreBluetooth BLE hardware is unsupported on this platform")
            self.sensorData.text = "CoreBluetooth BLE hardware is unsupported on this platform\n"
            break
            
        default:
            break
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        central.connectPeripheral(peripheral, options: nil)
        
        if (peripheral.name == "WAX9-ABAB") {
            
            self.discoveredPeripheral = peripheral
            
            println("PERIPHERAL NAME: \(peripheral.name)\n AdvertisementData: \(advertisementData)\n RSSI: \(RSSI)\n")
            
            println("UUID DESCRIPTION: \(peripheral.identifier.UUIDString)\n")
            
            println("IDENTIFIER: \(peripheral.identifier)\n")
            
            sensorData.text = sensorData.text + "FOUND PERIPHERALS: \(peripheral) AdvertisementData: \(advertisementData) RSSI: \(RSSI)\n"
            
            cManager.stopScan()
        }
        else {
            scanForWAX9(self)
        }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
        println("Connected to peripheral")
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        sensorData.text = "FAILED TO CONNECT \(error)"
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        
        switch peripheralManager.state {
            
        case .PoweredOff:
            sensorData.text = "Peripheral - CoreBluetooth BLE hardware is powered off"
            break
            
        case .PoweredOn:
            sensorData.text = "Peripheral - CoreBluetooth BLE hardware is powered on and ready"
            break
            
        case .Resetting:
            sensorData.text = "Peripheral - CoreBluetooth BLE hardware is resetting"
            break
            
        case .Unauthorized:
            sensorData.text = "Peripheral - CoreBluetooth BLE state is unauthorized"
            break
            
        case .Unknown:
            sensorData.text = "Peripheral - CoreBluetooth BLE state is unknown"
            break
            
        case .Unsupported:
            sensorData.text = "Peripheral - CoreBluetooth BLE hardware is unsupported on this platform"
            break
            
        default:
            break
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        println("ERROR: \(error)")
        
        var svc:CBService
        
        for svc in peripheral.services {
            println("Service \(svc)\n")
            sensorData.text = sensorData.text + "\(svc)\n"
            println("Discovering Characteristics for Service : \(svc)")
            peripheral.discoverCharacteristics(nil, forService: svc as CBService)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!)
    {
        var serviceUDID = CBUUID(string: "00000000-0008-A8BA-E311-F48C90364D99")
        var writeUDID = CBUUID(string: "00000001-0008-A8BA-E311-F48C90364D99")
        var notifyUDID = CBUUID(string: "00000002-0008-A8BA-E311-F48C90364D99")
        
        if (service.UUID == serviceUDID) {
            var streamMessage = NSData(bytes: [1] as [Byte], length: 1)
            
            peripheral.setNotifyValue(true, forCharacteristic: service.characteristics[2] as CBCharacteristic)
            
            peripheral.writeValue(streamMessage, forCharacteristic: service.characteristics[1] as CBCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        println("\nCharacteristic \(characteristic.description) isNotifying: \(characteristic.isNotifying)\n")
        
        //sensorData.text = sensorData.text + "\nCharacteristic \(characteristic.description) isNotifying: \(characteristic.isNotifying)\n"
        
        var ax = 0, ay = 0, az = 0, gx = 0, gy = 0, gz = 0, mx = 0, my = 0, mz = 0

        if ((characteristic.value) != nil) {
            var mylength = characteristic.value.length;
            //var buffer = [Byte](count: mylength, repeatedValue: 0)
            var buffer = [Byte](count: mylength, repeatedValue: 0)
            
            println("Length - \(mylength)");
            
            characteristic.value.getBytes(&buffer, length: mylength)
            
            if (mylength >= 2+6) {
                ax = ((Int(buffer[ 3]) * 256) + Int(buffer[ 2]))
                ay = ((Int(buffer[ 5]) * 256) + Int(buffer[ 4]))
                az = ((Int(buffer[ 7]) * 256) + Int(buffer[ 6]))
            }
            
            if (mylength >= 2+12) {
                gx = ((Int(buffer[ 9]) * 256) + Int(buffer[ 8]))
                gy = ((Int(buffer[11]) * 256) + Int(buffer[10]))
                gz = ((Int(buffer[13]) * 256) + Int(buffer[12]))
            }

            if (characteristic.value.length >= 2+18) {
                mx = ((Int(buffer[15]) * 256) + Int(buffer[14]))
                my = ((Int(buffer[17]) * 256) + Int(buffer[16]))
                mz = ((Int(buffer[19]) * 256) + Int(buffer[18]))
            }
        }

        println("\nax=\(ax) ay=\(ay) az=\(az) gx=\(gx) gy=\(gy) gz=\(gz) mx=\(mx) my=\(my) mz=\(mz)\n")
        sensorData.text = sensorData.text + "\nax=\(ax) ay=\(ay) az=\(az) gx=\(gx) gy=\(gy) gz=\(gz) mx=\(mx) my=\(my) mz=\(mz)\n"
        
        //if characteristic.isNotifying == true {
            //peripheral.readValueForCharacteristic(characteristic as CBCharacteristic)
        //}
        
        peripheral.setNotifyValue(true, forCharacteristic: characteristic as CBCharacteristic)
    }
}

