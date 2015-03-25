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
    let detector:InteractionDetector
    var initialHeading:CLLocationDirection!
    var initialPitch:CGFloat!
    var touchPitch:Float!
    var touchRoll:Float!

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
            initialHeading = self.camera.heading
            initialPitch = self.camera.pitch
            touchPitch = rad2deg(data.pitch)
            touchRoll = rad2deg(data.roll)
            
            WaxProcessor.getProcessor().dataCache.subscribe(dataCallback)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if (detector.touchDown) {
            detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
            WaxProcessor.getProcessor().dataCache.clearSubscriptions()
        }
    }
    
    func dataCallback(data:WaxData) {
        let ypr = data.getYawPitchRoll()
        let pitch = rad2deg(ypr.pitch) * -1.0
        let roll = rad2deg(ypr.roll)
        let newPitch = CGFloat(touchPitch - pitch)
        let newRoll = CLLocationDirection(touchRoll - roll)
        
        let newCamera = self.camera
        
        newCamera.pitch = initialPitch + newPitch
        newCamera.heading = initialHeading + newRoll
        
        self.setCamera(newCamera, animated: true)
    }
    
    private func rad2deg(radians:Float) -> Float {
        return radians / Float((M_PI / 180))
    }
}