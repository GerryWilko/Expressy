//
//  SensorConnectionManager.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation
import CoreBluetooth
import WatchConnectivity
import CoreMotion

class SensorConnectionManager: NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate, MSBClientManagerDelegate, WCSessionDelegate
{
    private static var connectionManager:SensorConnectionManager!
    
    private var cManager = CBCentralManager()
    private var peripheralManager = CBPeripheralManager()
    private var ready:Bool
    private var readyCallbacks:[() -> Void]
    private var connectionCallback:((error:NSError?) -> Void)!
    
    private var msAccData:MSBSensorAccelerometerData?
    private var msGyroData:MSBSensorGyroscopeData?
    
    /// Initialises a new connection manager to handle Bluetooth connection to sensor.
    /// - returns: New SensorConnectionManager instance.
    override init() {
        assert(SensorConnectionManager.connectionManager == nil)
        
        ready = false
        readyCallbacks = Array<() -> Void>()
        
        super.init()
        
        cManager = CBCentralManager(delegate: self, queue:nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        MSBClientManager.sharedManager().delegate = self
        
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
    
    func subscribeReady(callback:() -> Void) {
        if (ready) {
            callback()
        } else {
            readyCallbacks.append(callback)
        }
    }
    
    
    func clearReadySubscriptions() {
        readyCallbacks.removeAll(keepCapacity: false)
    }
    
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
            readyCallbacks.forEach({ (cb) -> () in
                cb()
            })
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
        if (peripheral.name != nil) {
            SensorScanVC.addDevice(peripheral)
        }
    }
    
    /// Function to connect to specfied peripheral.
    /// - parameter peripheral: Peripheral to connect to.
    func connectPeripheral(peripheral: CBPeripheral, completedCallback:(error: NSError?) -> Void) {
        connectionCallback = completedCallback
        cManager.connectPeripheral(peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("FAILED TO CONNECT \(error)")
        
        connectionCallback(error: error)
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
        let sampleRateServiceUDID = CBUUID(string: "00000005-0008-A8BA-E311-F48C90364D99")
        
        var serviceList = peripheral.services!.filter{ $0.UUID == serviceUDID || $0.UUID == sampleRateServiceUDID }
        
        if (serviceList.count > 0) {
            peripheral.discoverCharacteristics(nil, forService: serviceList[0])
        } else {
            connectionCallback(error: NSError(domain: "bluetooth", code: 1, userInfo: ["message": "Selected sensor does not have the required services."]))
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        let notifyUUID = CBUUID(string: "00000002-0008-A8BA-E311-F48C90364D99")
        let writeUUID = CBUUID(string: "00000001-0008-A8BA-E311-F48C90364D99")
        let sampleRateUUID = CBUUID(string: "0000000A-0008-A8BA-E311-F48C90364D99")
        
        if let sampleRateCharac = service.characteristics?.filter({$0.UUID == sampleRateUUID}).first {
            let sampleRateMessage = NSData(bytes: [50] as [UInt8], length: 1)
            peripheral.writeValue(sampleRateMessage, forCharacteristic: sampleRateCharac, type: .WithoutResponse)
        }
        
        if let notifyCharac = service.characteristics?.filter({ $0.UUID == notifyUUID }).first {
            peripheral.setNotifyValue(true, forCharacteristic: notifyCharac)
        }
        
        if let writeCharac = service.characteristics?.filter({ $0.UUID == writeUUID }).first {
            let streamMessage = NSData(bytes: [1] as [UInt8], length: 1)
            peripheral.writeValue(streamMessage, forCharacteristic: writeCharac, type: .WithoutResponse)
        }
        
        connectionCallback(error: nil)
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic,
        error: NSError?) {
        SensorProcessor.updateCache(characteristic.value!)
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if(characteristic.isNotifying)
        {
            peripheral.readValueForCharacteristic(characteristic);
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        let nav = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController as! UINavigationController
        nav.popToRootViewControllerAnimated(true)
        (nav.topViewController as! MenuVC).connectDeviceBtn.enabled = true
        
        let alert = UIAlertController(title: "Sensor Disconnected", message: "Connection to the sensor has been lost. You have been returned to the main menu.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        nav.topViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    func connectMSB() {
        let client = MSBClientManager.sharedManager().attachedClients().first as! MSBClient
        MSBClientManager.sharedManager().connectClient(client)
    }
    
    func clientManager(clientManager: MSBClientManager!, clientDidConnect client: MSBClient!) {
        do {
            try client.sensorManager.startAccelerometerUpdatesToQueue(nil, withHandler: accDataCallback)
            try client.sensorManager.startGyroscopeUpdatesToQueue(nil, withHandler: gyroDataCallback) 
        } catch let error as NSError {
            print(error)
        }
    }
    
    func accDataCallback(data:MSBSensorAccelerometerData!, error:NSError!) {
        if let gyro = msGyroData {
            SensorProcessor.updateCache(Float(data.x), ay: Float(data.y), az: Float(data.z), gx: Float(gyro.x), gy: Float(gyro.y), gz: Float(gyro.z), mx: nil, my: nil, mz: nil)
            msGyroData = nil
        } else {
            msAccData = data
        }
    }
    
    func gyroDataCallback(data:MSBSensorGyroscopeData!, error:NSError!) {
        if let acc = msAccData {
            SensorProcessor.updateCache(Float(acc.x), ay: Float(acc.y), az: Float(acc.z), gx: Float(data.x), gy: Float(data.y), gz: Float(data.z), mx: nil, my: nil, mz: nil)
            msAccData = nil
        } else {
            msGyroData = data
        }
    }
    
    func clientManager(clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
        let nav = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController as! UINavigationController
        nav.popToRootViewControllerAnimated(true)
        (nav.topViewController as! MenuVC).connectDeviceBtn.enabled = true
        
        let alert = UIAlertController(title: "Sensor Disconnected", message: "Connection to the sensor has been lost. You have been returned to the main menu.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        nav.topViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    func clientManager(clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: NSError!) {
        print(error)
    }
    
    @available(iOS 9.0, *)
    func startAppleWatchSensorUpdates() {
        WCSession.defaultSession().delegate = self
        WCSession.defaultSession().activateSession()
    }
    
    @available(iOS 9.0, *)
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let accData = message["accData"] as! CMAccelerometerData
        let gyroData = message["gyroData"] as! CMGyroData
        SensorProcessor.updateCache(Float(accData.acceleration.x), ay: Float(accData.acceleration.y), az: Float(accData.acceleration.z), gx: Float(gyroData.rotationRate.x), gy: Float(gyroData.rotationRate.y), gz: Float(gyroData.rotationRate.z), mx: nil, my: nil, mz: nil)
    }
}