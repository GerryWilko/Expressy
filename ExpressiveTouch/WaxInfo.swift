//
//  WaxInfo.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 20/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class WaxInfo {
    let time:NSTimeInterval, madgwick:Vector4D
    var startRecording:Bool, stopRecording:Bool, tapped:Bool, pinched:Bool, rotated:Bool, swiped:Bool, panned:Bool, edgePan:Bool, longPress:Bool
    
    init(time:NSTimeInterval, madgwick:Vector4D) {
        self.time = time
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

struct Vector4D {
    let x:Float, y:Float, z:Float, w:Float
}