//
//  WaxCache.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class WaxCache {
    private let limit:UInt
    private var items:[WaxData]
    private var count:UInt
    
    init(limit:UInt) {
        self.limit = limit
        items = [WaxData]()
        count = 0;
    }
    
    func push(item: WaxData) {
        if (count >= limit) {
            items.removeAtIndex(0)
            count--
        }
        items.append(item)
        count++
    }
    
    func get(index:UInt) -> WaxData {
        return items[Int(index)]
    }
    
    func length() -> UInt {
        return count
    }
}