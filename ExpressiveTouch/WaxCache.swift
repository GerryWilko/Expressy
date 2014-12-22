//
//  WaxCache.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class WaxCache {
    private let limit:Int
    private var items:[WaxData]
    
    init(limit:Int) {
        self.limit = limit
        self.items = [WaxData]()
    }
    
    func push(item: WaxData) {
        if (items.count >= limit) {
            items.removeAtIndex(0)
        }
        
        items.append(item)
    }
    
    func get(index:UInt) -> WaxData {
        return items[Int(index)]
    }
    
    func count() -> Int {
        return items.count
    }
}