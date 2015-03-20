//
//  WaxCache.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class WaxCache {
    private var data:[WaxData]
    private var dataCallbacks:[(data:WaxData) -> Void]
    
    private let limit:UInt = 1000
    
    init() {
        data = [WaxData]()
        dataCallbacks = Array<(data:WaxData) -> Void>()
    }
    
    func add(newData: WaxData) {
        if (UInt(data.count) >= limit) {
            data.removeAtIndex(0)
        }
        data.append(newData)
        fireDataCallbacks(newData)
    }
    
    subscript(index: Int) -> WaxData {
        get {
            return data[index]
        }
    }
    
    subscript(startIndex:Int, endIndex:Int) -> Array<WaxData> {
        return Array(data[startIndex..<endIndex])
    }
    
    func subscribe(callback:(data:WaxData) -> Void) {
        dataCallbacks.append(callback)
    }
    
    func clearSubscriptions() {
        dataCallbacks.removeAll(keepCapacity: false)
    }
    
    private func fireDataCallbacks(data:WaxData) {
        for cb in dataCallbacks {
            cb(data: data)
        }
    }
    
    func count() -> Int {
        return data.count
    }
    
    private func getIndexForTime(time:NSTimeInterval) -> Int {
        var closest:Int = 0
        for i in 0..<count() {
            if(abs(time - self[closest].time) > abs(self[i].time - time)) {
                closest = i;
            }
        }
        return closest;
    }
    
    func getForTime(time:NSTimeInterval) -> WaxData {
        return self[getIndexForTime(time)]
    }
    
    func getRangeForTime(start:NSTimeInterval, end:NSTimeInterval) -> [WaxData] {
        let startIndex = getIndexForTime(start)
        let endIndex = getIndexForTime(end)
        
        return self[startIndex, endIndex]
    }
}