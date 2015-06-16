//
//  SensorProcessor.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

var sensorProcessor:SensorProcessor!

class SensorProcessor {
    /// Central application data cache.
    let dataCache:SensorCache
    private let accNorm:Float = 4096.0
    private let gyroNorm:Float = 0.07
    private let magNorm:Float = 0.1
    
    /// Initialises a new sensor data processor for processing Bluetooth packets into sensor data objects.
    /// - returns: New SensorProcessor instance.
    init() {
        assert(sensorProcessor == nil)
        dataCache = SensorCache()
        sensorProcessor = self
    }
    
    /// Function to retrieve instance of SensorProcessor (currently required due to lack of static variable support in Swift).
    /// - returns: Instance of SensorProcessor.
    class func getProcessor() -> SensorProcessor { return sensorProcessor }
    
    /// Function to pass new Bluetooth packet to be processed into raw sensor data. Also handles calculation of Madgwick quaternion.
    /// - parameter data: Bluetooth packet.
    func updateCache(data:NSData) {
        let dataLength = data.length
        
        assert( dataLength == 20 )
        
        var buffer = [UInt8](count: dataLength, repeatedValue: 0)
        
        data.getBytes(&buffer, length: dataLength)
        
        let ax = CFloat((CShort(buffer[ 3]) << 8) + CShort(buffer[ 2])) / accNorm
        let ay = CFloat((CShort(buffer[ 5]) << 8) + CShort(buffer[ 4])) / accNorm
        let az = CFloat((CShort(buffer[ 7]) << 8) + CShort(buffer[ 6])) / accNorm
        
        let gx = CFloat((CShort(buffer[ 9]) << 8) + CShort(buffer[ 8])) * gyroNorm
        let gy = CFloat((CShort(buffer[11]) << 8) + CShort(buffer[10])) * gyroNorm
        let gz = CFloat((CShort(buffer[13]) << 8) + CShort(buffer[12])) * gyroNorm
        
        let mx = CFloat((CShort(buffer[15]) << 8) + CShort(buffer[14])) * magNorm
        let my = CFloat((CShort(buffer[17]) << 8) + CShort(buffer[16])) * magNorm
        let mz = CFloat((CShort(buffer[19]) << 8) + CShort(buffer[18])) * magNorm
        
        MadgwickAHRSupdateIMU(MathUtils.deg2rad(gx), MathUtils.deg2rad(gy), MathUtils.deg2rad(gz), ax, ay, az)
        
        let time = NSDate.timeIntervalSinceReferenceDate()
        let data = SensorData(time: time, ax: ax, ay: ay, az: az, gx: gx, gy: gy, gz: gz, mx: mx, my: my, mz: mz, qx: q0, qy: q1, qz: q2, qw: q3)
        
        dataCache.add(data)
    }
}