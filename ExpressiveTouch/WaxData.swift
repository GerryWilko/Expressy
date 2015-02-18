//
//  SensorData.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class WaxData: NilLiteralConvertible {
    let time:Int, x:Double, y:Double, z:Double, madgwick:Vector4D
    var startRecording:Bool, stopRecording:Bool, tapped:Bool, pinched:Bool, rotated:Bool, swiped:Bool, panned:Bool, edgePan:Bool, longPress:Bool
    
    required init(nilLiteral: ()) {
        self.time = 0
        
        self.x = 0
        self.y = 0
        self.z = 0
        
        self.madgwick = Vector4D(x:0,y:0,z:0,w:0)
        
        startRecording = false
        stopRecording = false
        tapped = false
        pinched = false
        rotated = false
        swiped = false
        panned = false
        edgePan = false
        longPress = false
    }
    
    init(time:Int, x:Double, y:Double, z:Double, madgwick:Vector4D) {
        self.time = time
        
        self.x = x
        self.y = y
        self.z = z
        
        self.madgwick = madgwick
        
        startRecording = false
        stopRecording = false
        tapped = false
        pinched = false
        rotated = false
        swiped = false
        panned = false
        edgePan = false
        longPress = false
    }
}

enum WaxDataAxis:Int {
    case X = 1, Y, Z
}

struct Vector4D {
    let x:Float, y:Float, z:Float, w:Float
}