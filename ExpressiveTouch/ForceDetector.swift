//
//  ForceDetector.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 27/01/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class ForceDetector {
    private var accCache:WaxCache
    
    init(accCache:WaxCache) {
        self.accCache = accCache
    }
    
    func getForce() -> Double {
        return calculateCurrentForce()
    }
    
    private func calculateCurrentForce() -> Double {
        var gForce = 0.0
        
        if (accCache.count() > 0) {
            var index = accCache.count() - 1
            var x = accCache.get(index).x / 9.81
            var y = accCache.get(index).y / 9.81
            var z = accCache.get(index).z / 9.81
            
            gForce = sqrt(x * x + y * y + z * z)
        }
        
        return gForce
    }
}