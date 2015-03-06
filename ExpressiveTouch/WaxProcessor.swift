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
    let accCache:WaxDataCache
    let gyroCache:WaxDataCache
    let magCache:WaxDataCache
    let infoCache:WaxInfoCache
    private let accNorm:Float = 4096.0
    private let gyroNorm:Float = 0.07
    private let magNorm:Float = 0.1
    
    init() {
        assert(waxProcessor == nil)
        
        accCache = WaxDataCache()
        gyroCache = WaxDataCache()
        magCache = WaxDataCache()
        infoCache = WaxInfoCache()
        
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
        
        MadgwickAHRSupdate(deg2rad(gx), deg2rad(gy), deg2rad(gz), ax, ay, az, mx, my, mz)
        let madgwick = Vector4D(x: q0, y: q1, z: q2, w: q3)
        
        let time = NSDate.timeIntervalSinceReferenceDate()
        
        accCache.add(WaxData(time: time, x: ax / accNorm, y: ay / accNorm, z: az / accNorm))
        gyroCache.add(WaxData(time: time, x: gx * gyroNorm, y: gy * gyroNorm, z: gz * gyroNorm))
        magCache.add(WaxData(time: time, x: mx * magNorm, y: my * magNorm, z: mz * magNorm))
        infoCache.add(WaxInfo(time: time, madgwick: madgwick))
    }
    
    func deg2rad(degrees:Float) -> Float {
        return Float((M_PI / 180)) * degrees
    }
    
    func startRecording() {
        infoCache.startRecording()
    }
    
    func stopRecording() {
        infoCache.stopRecording()
    }
    
    func tapped() {
        infoCache.tapped()
    }
    
    func pinched() {
        infoCache.pinched()
    }
    
    func rotated() {
        infoCache.rotated()
    }
    
    func swiped() {
        infoCache.swiped()
    }
    
    func panned() {
        infoCache.panned()
    }
    
    func edgePan() {
        infoCache.edgePan()
    }
    
    func longPress() {
        infoCache.longPress()
    }
}