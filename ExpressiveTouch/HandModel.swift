//
//  HandModel.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class HandModel {
    private var handState:HandState!
    
    init(madgwick:Vector4D) {
        handState = detectState(madgwick)
    }
    
    private func detectState(madgwick:Vector4D) -> HandState {
        let initialPos = Vector3D(x: 0, y: 0, z: 0)
        
        let madgPos = initialPos * madgwick
        if (madgPos.x == 1) {
            return .PalmDown
        } else if (madgPos.x == -1) {
            return .PalmUp
        } else if (madgPos.y == 1) {
            return .ThumbUp
        } else if (madgPos.y == -1) {
            return .ThumbDown
        }
        
        return .Unknown
    }
    
    func updateState(madgwick:Vector4D) {
        
    }
    
    func getState() -> HandState {
        return handState
    }
}

enum HandState {
    case PalmDown, PalmUp, ThumbUp, ThumbDown, Unknown
}