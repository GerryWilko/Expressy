//
//  ETMapView.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 18/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import MapKit

class ETMapView: MKMapView {
    private var lastPitch:Float!
    private var lastRoll:Float!
    
    let detector:InteractionDetector
    private let pitchBound:CGFloat = 50.0

    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        detector.startDetection()
        super.init(coder: aDecoder)
        
        self.showsBuildings = true
        
        let userCoordinate = CLLocationCoordinate2D(latitude: 51.5033, longitude: -0.11967)
        let eyeCoordinate = CLLocationCoordinate2D(latitude: 51.5033, longitude: -0.11967)
        let mapCamera = MKMapCamera(lookingAtCenterCoordinate: userCoordinate, fromEyeCoordinate: eyeCoordinate, eyeAltitude: 400.0)
        self.setCamera(mapCamera, animated: true)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if (!detector.touchDown) {
            detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
            
            let data = WaxProcessor.getProcessor().dataCache.getForTime(NSDate.timeIntervalSinceReferenceDate()).getYawPitchRoll()
            lastPitch = rad2deg(data.pitch)
            lastRoll = rad2deg(data.roll)
            
            WaxProcessor.getProcessor().dataCache.subscribe(dataCallback)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        if (detector.touchDown) {
            detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
            WaxProcessor.getProcessor().dataCache.clearSubscriptions()
        }
    }
    
    func dataCallback(data:WaxData) {
        let ypr = data.getYawPitchRoll()
        let pitch = rad2deg(ypr.pitch)
        let roll = rad2deg(ypr.roll)
        let pitchChange = CGFloat(pitch - lastPitch)
        let rollChange = CLLocationDirection(roll - lastRoll)
        
        var newPitch = self.camera.pitch + pitchChange
        var newRoll = self.camera.heading + rollChange
        
        if (newPitch < 0) {
            newPitch = 0
        } else if (newPitch > pitchBound) {
            newPitch = pitchBound
        }
        
        self.camera.pitch = newPitch
        self.camera.heading = newRoll
        
        lastPitch = pitch
        lastRoll = roll
    }
    
    private func rad2deg(radians:Float) -> Float {
        return radians / Float((M_PI / 180))
    }
}