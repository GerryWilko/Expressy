//
//  MapGestureRecognizer.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 30/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import MapKit

class MapGestureRecognizer: UIGestureRecognizer {
    var map:ETMapView!
    private var lastPitch:Float!
    private var lastRoll:Float!
    
    private let pitchBound:CGFloat = 50.0
    
    func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let data = WaxProcessor.getProcessor().dataCache.getForTime(NSDate.timeIntervalSinceReferenceDate()).getYawPitchRoll()
        lastPitch = rad2deg(data.pitch)
        lastRoll = rad2deg(data.roll)
        
        WaxProcessor.getProcessor().dataCache.subscribe(dataCallback)
    }
    
    func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        WaxProcessor.getProcessor().dataCache.clearSubscriptions()
    }
    
    func dataCallback(data:WaxData) {
        let ypr = data.getYawPitchRoll()
        let pitch = rad2deg(ypr.pitch)
        let roll = rad2deg(ypr.roll)
        let pitchChange = CGFloat(pitch - lastPitch)
        let rollChange = CLLocationDirection(roll - lastRoll)
        
        var newPitch = map.camera.pitch + pitchChange
        var newRoll = map.camera.heading + rollChange
        
        if (newPitch < 0) {
            newPitch = 0
        } else if (newPitch > pitchBound) {
            newPitch = pitchBound
        }
        
        map.camera.pitch = newPitch
        map.camera.heading = newRoll
        
        lastPitch = pitch
        lastRoll = roll
    }
    
    private func rad2deg(radians:Float) -> Float {
        return radians / Float((M_PI / 180))
    }
}