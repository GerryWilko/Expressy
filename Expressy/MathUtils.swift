//
//  MathUtils.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 09/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class MathUtils {
    class func deg2rad(degrees:Float) -> Float {
        return Float((M_PI / 180)) * degrees
    }
    
    class func rad2deg(radians:Float) -> Float {
        return radians * Float((M_PI / 180))
    }
}