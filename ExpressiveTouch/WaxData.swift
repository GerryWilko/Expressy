//
//  SensorData.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class WaxData {
    let time:NSTimeInterval, acc:Vector3D, gyro:Vector3D, mag:Vector3D, q:Vector4D, grav:Vector3D
    
    var touch:Bool, touchForce:Float
    
    init(time:NSTimeInterval, ax:Float, ay:Float, az:Float, gx:Float, gy:Float, gz:Float, mx:Float, my:Float, mz:Float, qx:Float, qy:Float, qz:Float, qw:Float) {
        self.time = time
        acc = Vector3D(x: ax, y: ay, z: az)
        gyro = Vector3D(x: gx, y: gy, z: gz)
        mag = Vector3D(x: mx, y: my, z: mz)
        q = Vector4D(x: qx, y: qy, z: qz, w: qw)
        
        let gravx = 2 * (q.y * q.w - q.x * q.z)
        let gravy = 2 * (q.x * q.y + q.z * q.w)
        let gravz = q.x * q.x - q.y * q.y - q.z * q.z + q.w * q.w
        grav = Vector3D(x: gravx, y: gravy, z: gravz)
        
        touch = false
        touchForce = 0.0
    }
    
    func getAccNoGrav() -> Vector3D {
        return Vector3D(x: acc.x - grav.x, y: acc.y - grav.y, z: acc.z - grav.z)
    }
    
    func touched(touchForce:Float) {
        touch = true
        self.touchForce = touchForce
    }
}

enum WaxDataAxis:Int {
    case X = 1, Y, Z
}