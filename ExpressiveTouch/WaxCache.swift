//
//  WaxCache.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class WaxCache: NilLiteralConvertible {
    private let limit:UInt = 10000
    private var items:[WaxData]
    
    required init(nilLiteral: ()) {
        items = [WaxData]()
    }
    
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