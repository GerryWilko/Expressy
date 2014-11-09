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
    
    @IBOutlet weak var accelX: UIProgressView!
    @IBOutlet weak var accelY: UIProgressView!
    @IBOutlet weak var accelZ: UIProgressView!
    
    @IBOutlet weak var gyroX: UIProgressView!
    @IBOutlet weak var gyroY: UIProgressView!
    @IBOutlet weak var gyroZ: UIProgressView!
    
    @IBOutlet weak var magX: UIProgressView!
    @IBOutlet weak var magY: UIProgressView!
    @IBOutlet weak var magZ: UIProgressView!
    
    @IBAction func scanForWAX9(sender: AnyObject) {
        cManager.scanForPeripheralsWithServices(nil, options: nil)
        println("\nNow Scanning for PERIPHERALS!\n")
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
            break
        case .PoweredOn:
            println("CoreBluetooth BLE hardware is powered on and ready")
            self.scanForWAX9(self)
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
        
        central.connectPeripheral(peripheral, options: nil)
        
        if (peripheral.name == "WAX9-ABAB") {
            
            self.discoveredPeripheral = peripheral
            
            println("PERIPHERAL NAME: \(peripheral.name)\n AdvertisementData: \(advertisementData)\n RSSI: \(RSSI)\n")
            
            println("UUID DESCRIPTION: \(peripheral.identifier.UUIDString)\n")
            
            println("IDENTIFIER: \(peripheral.identifier)\n")
            
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
        println("ERROR: \(error)")
        
        var serviceUDID = CBUUID(string: "00000000-0008-A8BA-E311-F48C90364D99")
        
        var serviceList = peripheral.services.filter{($0 as CBService).UUID == serviceUDID }
        
        peripheral.discoverCharacteristics(nil, forService: serviceList[0] as CBService)
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!)
    {
        var writeUDID = CBUUID(string: "00000001-0008-A8BA-E311-F48C90364D99")
        var notifyUDID = CBUUID(string: "00000002-0008-A8BA-E311-F48C90364D99")
        
        var streamMessage = NSData(bytes: [1] as [Byte], length: 1)
            
        peripheral.setNotifyValue(true, forCharacteristic: service.characteristics[2] as CBCharacteristic)
            
        peripheral.writeValue(streamMessage, forCharacteristic: service.characteristics[1] as CBCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        println("\nCharacteristic \(characteristic.description) isNotifying: \(characteristic.isNotifying)\n")
        
        var ax = 0, ay = 0, az = 0, gx = 0, gy = 0, gz = 0, mx = 0, my = 0, mz = 0

        if ((characteristic.value) != nil) {
            var mylength = characteristic.value.length;
            var buffer = [Byte](count: mylength, repeatedValue: 0)
            
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
        
        var maxValue:Float = 70000;
        
        var axPerc = (Float(ax) / maxValue);
        accelX.setProgress(axPerc, animated: false)
        var ayPerc = (Float(ay) / maxValue);
        accelY.setProgress(ayPerc, animated: false)
        var azPerc = (Float(az) / maxValue);
        accelZ.setProgress(azPerc, animated: false)
        
        var gxPerc = (Float(gx) / maxValue);
        gyroX.setProgress(gxPerc, animated: false)
        var gyPerc = (Float(gy) / maxValue);
        gyroY.setProgress(gyPerc, animated: false)
        var gzPerc = (Float(gz) / maxValue);
        gyroZ.setProgress(gzPerc, animated: false)
        
        var mxPerc = (Float(mx) / maxValue);
        accelX.setProgress(mxPerc, animated: false)
        var myPerc = (Float(my) / maxValue);
        accelY.setProgress(myPerc, animated: false)
        var mzPerc = (Float(mz) / maxValue);
        accelZ.setProgress(mzPerc, animated: false)
        
        peripheral.setNotifyValue(true, forCharacteristic: characteristic as CBCharacteristic)
    }
}

