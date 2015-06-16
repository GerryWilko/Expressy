//
//  SensorProcessor.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class SensorProcessor {
    /// Central application data cache.
    static let dataCache = SensorCache()
    private static let accNorm:Float = 4096.0
    private static let gyroNorm:Float = 0.07
    private static let magNorm:Float = 0.1
    
    /// Function to pass new Bluetooth packet to be processed into raw sensor data. Also handles calculation of Madgwick quaternion.
    /// - parameter data: Bluetooth packet.
    class func updateCache(data:NSData) {
        let dataLength = data.length
        
        assert( dataLength == 20 )
        
        var buffer = [UInt8](count: dataLength, repeatedValue: 0)
        
        data.getBytes(&buffer, length: dataLength)
        
        let ax = Float((CShort(buffer[ 3]) << 8) + CShort(buffer[ 2])) / accNorm
        let ay = Float((CShort(buffer[ 5]) << 8) + CShort(buffer[ 4])) / accNorm
        let az = Float((CShort(buffer[ 7]) << 8) + CShort(buffer[ 6])) / accNorm
        
        let gx = Float((CShort(buffer[ 9]) << 8) + CShort(buffer[ 8])) * gyroNorm
        let gy = Float((CShort(buffer[11]) << 8) + CShort(buffer[10])) * gyroNorm
        let gz = Float((CShort(buffer[13]) << 8) + CShort(buffer[12])) * gyroNorm
        
        let mx = Float((CShort(buffer[15]) << 8) + CShort(buffer[14])) * magNorm
        let my = Float((CShort(buffer[17]) << 8) + CShort(buffer[16])) * magNorm
        let mz = Float((CShort(buffer[19]) << 8) + CShort(buffer[18])) * magNorm
        
        self.updateCache(ax, ay: ay, az: az, gx: gx, gy: gy, gz: gz, mx: mx, my: my, mz: mz)
    }
    
    class func updateCache(ax: Float, ay: Float, az: Float, gx: Float, gy: Float, gz: Float, mx: Float?, my: Float?, mz: Float?) {
        MadgwickAHRSupdateIMU(MathUtils.deg2rad(gx), MathUtils.deg2rad(gy), MathUtils.deg2rad(gz), ax, ay, az)
        
        let time = NSDate.timeIntervalSinceReferenceDate()
        let data = SensorData(time: time, ax: ax, ay: ay, az: az, gx: gx, gy: gy, gz: gz, mx: mx, my: my, mz: mz, qx: q0, qy: q1, qz: q2, qw: q3)
        
        dataCache.add(data)
    }
}