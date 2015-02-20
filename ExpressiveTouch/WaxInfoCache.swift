//
//  WaxInfoCache.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 20/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class WaxInfoCache {
    private let info:WaxCache<WaxInfo>
    
    init() {
        info = WaxCache<WaxInfo>()
    }
    
    func get(index:Int) -> WaxInfo {
        return info.items[index]
    }
    
    func add(newInfo:WaxInfo) {
        info.push(newInfo)
    }
    
    func count() -> Int {
        return info.count()
    }
    
    private func getIndexForTime(time:NSTimeInterval) -> Int {
        var closest:Int = 0
        for i in 0..<info.count() {
            if(abs(time - get(closest).time) > abs(get(i).time - time)) {
                closest = i;
            }
        }
        return closest;
    }
    
    func getForTime(time:NSTimeInterval) -> WaxInfo {
        return get(getIndexForTime(time))
    }
    
    func getRangeForTime(start:NSTimeInterval, end:NSTimeInterval) -> [WaxInfo] {
        let startIndex = getIndexForTime(start)
        let endIndex = getIndexForTime(end)
        
        return info.getRange(startIndex, endIndex: endIndex)
    }
    
    func startRecording() {
        if (info.count() > 0) { info.items[info.count() - 1].startRecording = true }
    }
    
    func stopRecording() {
        if (info.count() > 0) { info.items[info.count() - 1].stopRecording = true }
    }
    
    func tapped() {
        if (info.count() > 0) { info.items[info.count() - 1].tapped = true }
    }
    
    func pinched() {
        if (info.count() > 0) { info.items[info.count() - 1].pinched = true }
    }
    
    func rotated() {
        if (info.count() > 0) { info.items[info.count() - 1].rotated = true }
    }
    
    func swiped() {
        if (info.count() > 0) { info.items[info.count() - 1].swiped = true }
    }
    
    func panned() {
        if (info.count() > 0) { info.items[info.count() - 1].panned = true }
    }
    
    func edgePan() {
        if (info.count() > 0) { info.items[info.count() - 1].edgePan = true }
    }
    
    func longPress() {
        if (info.count() > 0) { info.items[info.count() - 1].longPress = true }
    }
}