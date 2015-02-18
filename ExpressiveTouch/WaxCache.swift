//
//  WaxCache.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class WaxCache {
    private let limit:UInt = 1000
    private var items:[WaxData]
    
    init() {
        items = [WaxData]()
    }
    
    func push(item: WaxData) {
        if (UInt(items.count) >= limit) {
            items.removeAtIndex(0)
        }
        items.append(item)
    }
    
    func get(index:UInt) -> WaxData {
        return items[Int(index)]
    }
    
    private func getIndexForTime(time:Int) -> Int {
        var closest:Int = 0
        for i in 0..<count() {
            if(abs(time - items[closest].time) > abs(items[i].time - time)) {
                closest = i;
            }
        }
        return closest;
    }
    
    func getForTime(time:Int) -> WaxData {
        return items[getIndexForTime(time)]
    }
    
    func getRangeForTime(start:Int, end:Int) -> [WaxData] {
        let startIndex = getIndexForTime(start)
        let endIndex = getIndexForTime(end)
        
        return Array(items[startIndex..<endIndex])
    }
    
    func count() -> Int {
        return items.count
    }
    
    func startRecording() {
        if (count() > 0) { items[count() - 1].startRecording = true }
    }
    
    func stopRecording() {
        if (count() > 0) { items[count() - 1].stopRecording = true }
    }
    
    func tapped() {
        if (count() > 0) { items[count() - 1].tapped = true }
    }
    
    func pinched() {
        if (count() > 0) { items[count() - 1].pinched = true }
    }
    
    func rotated() {
        if (count() > 0) { items[count() - 1].rotated = true }
    }
    
    func swiped() {
        if (count() > 0) { items[count() - 1].swiped = true }
    }
    
    func panned() {
        if (count() > 0) { items[count() - 1].panned = true }
    }
    
    func edgePan() {
        if (count() > 0) { items[count() - 1].edgePan = true }
    }
    
    func longPress() {
        if (count() > 0) { items[count() - 1].longPress = true }
    }
}