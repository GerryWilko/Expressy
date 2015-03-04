//
//  Vector.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 04/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

struct Vector3D {
    let x:Float, y:Float, z:Float
}

struct Vector4D {
    let x:Float, y:Float, z:Float, w:Float
}

func * (left: Vector3D, right: Vector4D) -> Vector3D {
    let rw1 = left.x * -right.x
    let rw2 = left.y * -right.y
    let rw3 = left.z * -right.z
    
    let rw =  -(rw1 + rw2 + rw3)
    let rx =   (left.y * -right.z - left.z * -right.y) + left.x * right.w
    let ry =   (left.z * -right.x - left.x * -right.z) + left.y * right.w
    let rz =   (left.x * -right.y - left.y * -right.x) + left.z * right.w
    
    let x = (right.y * rz - right.z*ry) + right.w * rx + right.x * rw
    let y = (right.z * rx - right.x * rz) + right.w * ry + right.y * rw
    let z = (right.x * ry - right.y * rx) + right.w * rz + right.z * rw
    
    return Vector3D(x: x, y: y, z: z)
}