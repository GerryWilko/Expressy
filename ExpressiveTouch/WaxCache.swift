//
//  WaxCache.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class WaxCache<T> {
    private let limit:UInt = 1000
    internal var items:[T]
    
    init() {
        items = [T]()
    }
    
    func push(item: T) {
        if (UInt(items.count) >= limit) {
            items.removeAtIndex(0)
        }
        items.append(item)
    }
    
    func getRange(startIndex:Int, endIndex:Int) -> Array<T> {
        return Array(items[startIndex..<endIndex])
    }
    
    func count() -> Int {
        return items.count
    }
}