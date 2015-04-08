//
//  MapGestureRecognizer.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 30/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import MapKit

class ETMapGestureView: UIView {
    var map:MKMapView!
    private var touchPitch:CGFloat!
    private var touchHeading:CLLocationDirection!
    private var touch:Bool = false
    
    private let pitchBound:CGFloat = 50.0
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        MadgwickAHRSreset()
        touchPitch = map.camera.pitch
        touchHeading = map.camera.heading
        WaxProcessor.getProcessor().dataCache.subscribe(dataCallback)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        WaxProcessor.getProcessor().dataCache.clearSubscriptions()
    }
    
    func dataCallback(data:WaxData) {
        let ypr = data.getYawPitchRoll()
        let pitch = rad2deg(ypr.pitch)
        let roll = rad2deg(ypr.roll)
        var newPitch = touchPitch + CGFloat(pitch)
        var newRoll = touchHeading + CLLocationDirection(roll)
        
        println("pitch: \(ypr.pitch), roll: \(ypr.roll)")
        
        if (newPitch < 0) {
            newPitch = 0
        } else if (newPitch > pitchBound) {
            newPitch = pitchBound
        }
        
        map.camera.pitch = newPitch
        map.camera.heading = newRoll
    }
    
    private func rad2deg(radians:Float) -> Float {
        return radians / Float((M_PI / 180))
    }
}