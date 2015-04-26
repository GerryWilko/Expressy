//
//  WaxData.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class WaxData {
    /// Time data was recieved.
    let time:NSTimeInterval
    /// Vector of accelerometer values.
    let acc:Vector3D
    /// Vector of gyroscope values.
    let gyro:Vector3D
    /// Vector of magnetometer values.
    let mag:Vector3D
    /// Madgwick quaternion representing sensor orientation.
    let q:Vector4D
    /// Vector of estimation of gravity.
    let grav:Vector3D
    
    var touch:TouchEvent, touchForce:Float
    
    /// Initialises a new sensor data instance for encapsulation of sensor data.
    /// :param: time Time data was recieved.
    /// :param: ax Accelerometer x-axis.
    /// :param: ay Accelerometer y-axis.
    /// :param: az Accelerometer z-axis.
    /// :param: gx Gyroscope x-axis.
    /// :param: gy Gyroscope y-axis.
    /// :param: gz Gyroscope z-axis.
    /// :param: mx Magnetometer x-axis.
    /// :param: my Magnetometer y-axis.
    /// :param: mz Magnetometer z-axis.
    /// :param: qx Quaternion x-axis.
    /// :param: qy Quaternion y-axis.
    /// :param: qz Quaternion z-axis.
    /// :param: qw Quaternion w-axis.
    /// :returns: WaxData instance.
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
        
        touch = TouchEvent.None
        touchForce = 0.0
    }
    
    /// Function to retrieve formatted header line for CSV export of sensor data.
    /// :returns: Comma-separated formatted header line for CSV export.
    class func headerLine() -> String {
        return "Time,ax,ay,az,gx,gy,gz,mx,my,mz,gravx,gravy,gravz,yaw,pitch,roll,Touch,Touch Force"
    }
    
    /// Function to retrieve the accelerometer values with the estimation of gravity removed providing 'pure' acceleration.
    /// :returns: Vector of 'pure' accelerometer values.
    func getAccNoGrav() -> Vector3D {
        return Vector3D(x: acc.x - grav.x, y: acc.y - grav.y, z: acc.z - grav.z)
    }
    
    /// Function to pass touch down event, places mark in sensor data for debugging purposes.
    /// :param: touchForce Value denoting force screen was struck.
    func touchDown(touchForce:Float) {
        touch = TouchEvent.Down
        self.touchForce = touchForce
    }
    
    /// Function to pass touch up event, places mark in sensor data for debuggin purposes.
    func touchUp() {
        touch = TouchEvent.Up
    }
    
    /// Function to retrieve yaw, pitch and roll from Madgwick Quaternion decomposition.
    /// :returns: Tuple of yaw, pitch and roll in radians.
    func getYawPitchRoll() -> (yaw:Float, pitch:Float, roll:Float) {
        let sgyz = sqrt(grav.y * grav.y + grav.z * grav.z)
        let sgxz = sqrt(grav.x * grav.x + grav.z * grav.z)
        
        let yaw = atan2(2 * q.y * q.z - 2 * q.x * q.w, 2 * q.x * q.x + 2 * q.y * q.y - 1)
        let pitch = (sgyz < 0.05) ? 0.0 : atan(grav.x / sgyz)
        let roll = (sgxz < 0.05) ? 0.0 : atan(grav.y / sgxz)
        
        return (yaw, pitch, roll)
    }
    
    /// Function to print sensor data in CSV format.
    /// :returns: Formatted string of sensor data.
    func print() -> String {
        let ypr = getYawPitchRoll()
        
        return "\(time),\(acc.x),\(acc.y),\(acc.z),\(gyro.x),\(gyro.y),\(gyro.z),\(mag.x),\(mag.y),\(mag.z),\(grav.x),\(grav.y),\(grav.z),\(ypr.yaw),\(ypr.pitch),\(ypr.roll),\(touch.rawValue),\(touchForce)"
    }
}

/// Enum for touch events.
/// - Down: Touch down event occurred when this data was received.
/// - Up: Touch up event occurred when this data was received.
/// - None: No touch event occurred.
enum TouchEvent:Int {
    case Down = 1, Up = -1, None = 0
}