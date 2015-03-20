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
    var timer:NSTimer!

    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        detector.startDetection()
        super.init(coder: aDecoder)
        
        self.showsBuildings = true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!detector.touchDown) {
            detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
            
            let data = WaxProcessor.getProcessor().dataCache.getForTime(NSDate.timeIntervalSinceReferenceDate()).getYawPitchRoll()
            initialHeading = self.camera.heading
            initialPitch = self.camera.pitch
            touchPitch = data.pitch
            touchRoll = data.roll
            
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("interactionCallback:"), userInfo: nil, repeats: true)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (detector.touchDown) {
            detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
            timer.invalidate()
        }
    }
    
    @objc func interactionCallback(timer:NSTimer) {
        let userCoordinate = CLLocationCoordinate2D(latitude: 51.5033, longitude: -0.11967)
        let eyeCoordinate = CLLocationCoordinate2D(latitude: 51.5033, longitude: -0.11967)
        let mapCamera = MKMapCamera(lookingAtCenterCoordinate: userCoordinate, fromEyeCoordinate: eyeCoordinate, eyeAltitude: 400.0)
        
        let data = WaxProcessor.getProcessor().dataCache.getForTime(NSDate.timeIntervalSinceReferenceDate()).getYawPitchRoll()
        mapCamera.pitch = initialPitch + CGFloat(touchPitch - (data.pitch * 100) * -1.0)
        mapCamera.heading = initialHeading + CLLocationDirection(touchRoll - (data.roll * 100))
        
        self.setCamera(mapCamera, animated: true)
    }
}