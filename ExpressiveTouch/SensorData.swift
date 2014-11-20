//
//  SensorData.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

struct SensorData {
    let x:Int, y:Int, z:Int
}

enum SensorDataType:Int {
    case AX = 1, AY, AZ, GX, GY, GZ, MX, MY, MZ
}
