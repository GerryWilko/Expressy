//
//  WaxCache.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class WaxCache {
    private var limit:Int
    private var items:[SensorData]
    
    init(limit:Int) {
        self.limit = limit
        self.items = [SensorData]()
    }
    
    func push(item: SensorData) {
        if (items.count >= limit) {
            items.removeLast()
        }
        
        items.append(item)
    }
    
    func get(index:UInt) -> SensorData {
        return items[Int(index)]
    }
    
    func count() -> Int {
        return items.count
    }
}