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
    
    @IBAction func scanForDevices(sender: AnyObject) {
        cManager.scanForPeripheralsWithServices(nil, options: nil)
        sensorData.text = "\nNow Scanning for PERIPHERALS!\n"
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
            
            central.connectPeripheral(peripheral, options: nil)
            
            // We have to set the discoveredPeripheral var we declared earlier to reference the peripheral, otherwise we won't be able to interact with it in didConnectPeripheral. And you will get state = connecting> is being dealloc'ed while pending connection error.
            
            self.discoveredPeripheral = peripheral
            
            var curDevice = UIDevice.currentDevice()
            
            //iPad or iPhone
            println("VENDOR ID: \(curDevice.identifierForVendor) BATTERY LEVEL: \(curDevice.batteryLevel)\n\n")
            println("DEVICE DESCRIPTION: \(curDevice.description) MODEL: \(curDevice.model)\n\n")
            
            // Hardware beacon
            println("PERIPHERAL NAME: \(peripheral.name)\n AdvertisementData: \(advertisementData)\n RSSI: \(RSSI)\n")
            
            println("UUID DESCRIPTION: \(peripheral.identifier.UUIDString)\n")
            
            println("IDENTIFIER: \(peripheral.identifier)\n")
            
            sensorData.text = sensorData.text + "FOUND PERIPHERALS: \(peripheral) AdvertisementData: \(advertisementData) RSSI: \(RSSI)\n"
            
            // stop scanning, saves the battery
            cManager.stopScan()
            
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
        sensorData.text = sensorData.text + "\n\nCHARACTERISTICS\n\n"
        var myCharacteristic = CBCharacteristic()
        
        for myCharacteristic in service.characteristics {
            sensorData.text = sensorData.text + "\nCharacteristic: \(myCharacteristic)\n"
            
            println("didDiscoverCharacteristicsForService - Service: \(service) Characteristic: \(myCharacteristic)\n\n")
            
            
            peripheral.readValueForCharacteristic(myCharacteristic as CBCharacteristic)
            
        }
    }
}

