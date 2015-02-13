//
//  InteractionDetector.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 03/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class InteractionDetector {
    private var timer:NSTimer
    
    init() {
        timer = NSTimer()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "processData", userInfo: nil, repeats: false)
    }
    
    func processData() {
        detectSweep()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "processData", userInfo: nil, repeats: false)
    }
    
    func detectSweep() {
        
    }
}