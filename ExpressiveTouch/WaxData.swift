//
//  SensorData.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

struct WaxData {
    let x:Double, y:Double, z:Double
    var touch:Bool = false
}

enum WaxDataAxis:Int {
    case X = 1, Y, Z
}
