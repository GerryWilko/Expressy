//
//  SensorData.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class WaxData {
    let x:Double, y:Double, z:Double
    var startRecording:Bool, stopRecording:Bool, tapped:Bool, pinched:Bool, rotated:Bool, swiped:Bool, panned:Bool, edgePan:Bool, longPress:Bool
    
    init(x:Double, y:Double, z:Double) {
        self.x = x
        self.y = y
        self.z = z
        
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