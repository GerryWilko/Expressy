//
//  HandModel.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class HandModel {
    private var pitch:Float!
    private var roll:Float!
    
    private let initialVec = Vector3D(x: 0, y: 0, z: 1)
    
    init(data:WaxData) {
        pitch = calculatePitch(data)
        roll = calculateRoll(data)
    }
    
    func updateState(data:WaxData) {
        pitch = calculatePitch(data)
        roll = calculateRoll(data)
    }
    
    private func calculatePitch(data:WaxData) -> Float {
        return data.grav.angleBetween(initialVec)
    }
    
    private func calculateRoll(data:WaxData) -> Float {
        return data.grav.angleBetween(initialVec)
    }
}