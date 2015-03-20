//
//  WaxProcessor.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

var waxProcessor:WaxProcessor!

class WaxProcessor {
    let dataCache:WaxCache
    private let accNorm:Float = 4096.0
    private let gyroNorm:Float = 0.07
    private let magNorm:Float = 0.1
    
    init() {
        assert(waxProcessor == nil)
        dataCache = WaxCache()
        waxProcessor = self
    }
    
    class func getProcessor() -> WaxProcessor { return waxProcessor }
    

    
    func updateCache(data:NSData) {
        var dataLength = data.length
        
        assert( dataLength == 20 )
        
        var buffer = [UInt8](count: dataLength, repeatedValue: 0)
        
        data.getBytes(&buffer, length: dataLength)
        
        var ax = CFloat(CShort(buffer[ 3]) << 8 + CShort(buffer[ 2])) / accNorm
        var ay = CFloat(CShort(buffer[ 5]) << 8 + CShort(buffer[ 4])) / accNorm
        var az = CFloat(CShort(buffer[ 7]) << 8 + CShort(buffer[ 6])) / accNorm
        
        var gx = CFloat(CShort(buffer[ 9]) << 8 + CShort(buffer[ 8])) * gyroNorm
        var gy = CFloat(CShort(buffer[11]) << 8 + CShort(buffer[10])) * gyroNorm
        var gz = CFloat(CShort(buffer[13]) << 8 + CShort(buffer[12])) * gyroNorm
        
        var mx = CFloat(CShort(buffer[15]) << 8 + CShort(buffer[14])) * magNorm
        var my = CFloat(CShort(buffer[17]) << 8 + CShort(buffer[16])) * magNorm
        var mz = CFloat(CShort(buffer[19]) << 8 + CShort(buffer[18])) * magNorm
        
        MadgwickAHRSupdateIMU(deg2rad(gx), deg2rad(gy), deg2rad(gz), ax, ay, az)
        
        let time = NSDate.timeIntervalSinceReferenceDate()
        let data = WaxData(time: time, ax: ax, ay: ay, az: az, gx: gx, gy: gy, gz: gz, mx: mx, my: my, mz: mz, qx: q0, qy: q1, qz: q2, qw: q3)
        
        dataCache.add(data)
    }
    
    private func deg2rad(degrees:Float) -> Float {
        return Float((M_PI / 180)) * degrees
    }
}