//
//  SensorData.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class WaxData {
    let time:NSTimeInterval, x:Double, y:Double, z:Double
    
    init(time:NSTimeInterval, x:Double, y:Double, z:Double) {
        self.time = time
        
        self.x = x
        self.y = y
        self.z = z
    }
}

enum WaxDataAxis:Int {
    case X = 1, Y, Z
}