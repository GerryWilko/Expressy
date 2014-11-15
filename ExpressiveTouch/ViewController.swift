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

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralManagerDelegate,CBPeripheralDelegate, CPTPlotDataSource {
    @IBOutlet weak var graphView: CPTGraphHostingView!
    
    func scanForWAX9(sender: AnyObject) {
        cManager.scanForPeripheralsWithServices(nil, options: nil)
        println("\nNow Scanning for PERIPHERALS!\n")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initPlot();
        
        cManager = CBCentralManager(delegate: self, queue:nil)
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        /*
        var graph = CPTXYGraph(frame: CGRectZero)
        
        graph.title = "WAX9 Data"
        
        graph.paddingTop = 0
        graph.paddingBottom = 0
        graph.paddingLeft = 0
        graph.paddingRight = 0
        
        var axes = graph.axisSet as CPTXYAxisSet
        var lineStyle = CPTMutableLineStyle()
        lineStyle.lineWidth = 0
        axes.xAxis.axisLineStyle = lineStyle
        axes.yAxis.axisLineStyle = lineStyle
        
        var plot = CPTPlot()
        plot.dataSource = self
        
        
        
        graph.addPlot(plot)
        self.graphView.hostedGraph = graph
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initPlot() {
        self.configureHost()
        self.configureGraph()
        self.configurePlots()
        self.configureAxes()
    }
    
    func configureHost() {
        self.graphView.allowPinchScaling = true
    }
    
    func configureGraph() {
        var graph = CPTXYGraph(frame: CGRectZero)
        self.graphView.hostedGraph = graph
    
        graph.title = "WAX9 Data"
        
        var titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.whiteColor()
        titleStyle.fontName = "Helvetica-Bold"
        titleStyle.fontSize = 16.0
        
        graph.titleTextStyle = titleStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop
        graph.titleDisplacement = CGPointMake(0.0, 10.0)
        
        graph.plotAreaFrame.paddingLeft = 30.0
        graph.plotAreaFrame.paddingBottom = 30.0
        
        graph.defaultPlotSpace.allowsUserInteraction = true
    }
    
    func configurePlots() {
        var graph = self.graphView.hostedGraph
        var plotSpace = graph.defaultPlotSpace
        
        var accPlot = CPTScatterPlot()
        var gyroPlot = CPTScatterPlot()
        var magPlot = CPTScatterPlot()
        
        accPlot.dataSource = self
        gyroPlot.dataSource = self
        magPlot.dataSource = self
        
        graph.addPlot(accPlot)
        graph.addPlot(gyroPlot)
        graph.addPlot(magPlot)
        
        plotSpace.scaleToFitPlots([accPlot, gyroPlot, magPlot])
        
    }
    
    func configureAxes() {
    }
    
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
        
        if (peripheral.name != nil && peripheral.name == "WAX9-ABAB") {
            
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
            
            var ax:CShort = 0;
            var ay:CShort = 0;
            var az:CShort = 0;
            var gx:CShort = 0;
            var gy:CShort = 0;
            var gz:CShort = 0;
            var mx:CShort = 0;
            var my:CShort = 0;
            var mz:CShort = 0;
            
            assert( characteristic.value != nil );
            
            var dataLength = characteristic.value.length;
            
            assert( dataLength == 20 );
            
            var buffer = [Byte](count: dataLength, repeatedValue: 0)
            
            characteristic.value.getBytes(&buffer, length: dataLength)
            
            ax = CShort(buffer[ 3]) << 8 + CShort(buffer[ 2])
            ay = CShort(buffer[ 5]) << 8 + CShort(buffer[ 4])
            az = CShort(buffer[ 7]) << 8 + CShort(buffer[ 6])
            
            gx = CShort(buffer[ 9]) << 8 + CShort(buffer[ 8])
            gy = CShort(buffer[11]) << 8 + CShort(buffer[10])
            gz = CShort(buffer[13]) << 8 + CShort(buffer[12])
            
            mx = CShort(buffer[15]) << 8 + CShort(buffer[14])
            my = CShort(buffer[17]) << 8 + CShort(buffer[16])
            mz = CShort(buffer[19]) << 8 + CShort(buffer[18])
            
            
            println("ax: \(ax), ay: \(ay),az: \(az), gx: \(gx), gy: \(gy), gz: \(gz), mx: \(mx), my: \(my), mz: \(mz)")
            
            var maxValue:Float = 5000;
            
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if( characteristic.isNotifying )
        {
            peripheral.readValueForCharacteristic(characteristic);
        }
    }
    
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        return 0
    }
    
    func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> NSNumber! {
        return 0
    }
}

