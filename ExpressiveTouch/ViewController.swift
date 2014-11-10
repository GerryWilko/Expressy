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
        
        println(peripheral.name);
        
        if (peripheral.name == "WAX9-ABAB") {
            
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
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        println("\nCharacteristic \(characteristic.description) isNotifying: \(characteristic.isNotifying)\n")
        
        var ax:CShort = 0;
        var ay:CShort = 0;
        var az:CShort = 0;
        var gx:CShort = 0;
        var gy:CShort = 0;
        var gz:CShort = 0;
        var mx:CShort = 0;
        var my:CShort = 0;
        var mz:CShort = 0;

        if ((characteristic.value) != nil) {
            var mylength = characteristic.value.length;
            
            assert( mylength == 20 );
            
            var buffer = [Byte](count: mylength, repeatedValue: 0)
            
            characteristic.value.getBytes(&buffer, length: mylength)
            
            //ax = Int((Int16(buffer[ 3]) << 8) + Int16(buffer[ 2]));
            //ay = Int((Int16(buffer[ 5]) << 8) + Int16(buffer[ 4]));
            //az = Int((Int16(buffer[ 7]) << 8) + Int16(buffer[ 6]));
            
            ax = ((CShort(buffer[ 3]) << 8) + CShort(buffer[ 2]));
            ay = ((CShort(buffer[ 5]) << 8) + CShort(buffer[ 4]));
            az = ((CShort(buffer[ 7]) << 8) + CShort(buffer[ 6]));
        }
        
        var axPerc = (Float(ax) / 100000.0);
        accelX.setProgress(axPerc, animated: true)
        var ayPerc = (Float(ay) / 100000.0);
        accelY.setProgress(ayPerc, animated: true)
        var azPerc = (Float(az) / 100000.0);
        accelZ.setProgress(azPerc, animated: true)
        
        var gxPerc = (Float(gx) / 100000.0);
        gyroX.setProgress(gxPerc, animated: true)
        var gyPerc = (Float(gy) / 100000.0);
        gyroY.setProgress(gyPerc, animated: true)
        var gzPerc = (Float(gz) / 100000.0);
        gyroZ.setProgress(gzPerc, animated: true)
        
        var mxPerc = (Float(mx) / 100000.0);
        accelX.setProgress(mxPerc, animated: true)
        var myPerc = (Float(my) / 100000.0);
        accelY.setProgress(myPerc, animated: true)
        var mzPerc = (Float(mz) / 100000.0);
        accelZ.setProgress(mzPerc, animated: true)
        
        peripheral.setNotifyValue(true, forCharacteristic: characteristic as CBCharacteristic)
    }
}

