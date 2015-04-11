//
//  ETMapGestureView.swift
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
    private let detector:InteractionDetector
    
    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        detector.startDetection()
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        MadgwickAHRSreset()
        touchPitch = map.camera.pitch
        touchHeading = map.camera.heading
        detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
        detector.subscribe(EventType.Metrics, callback: metricCallback)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
        detector.clearSubscriptions()
    }
    
    func metricCallback(data:Float!) {
        var newPitch = touchPitch + CGFloat(-detector.currentPitch * 3)
        var newRoll = touchHeading + CLLocationDirection(detector.currentRotation)
        
        if (newPitch < 0) {
            newPitch = 0
        } else if (newPitch > pitchBound) {
            newPitch = pitchBound
        }
        
        let camera = map.camera.copy() as! MKMapCamera
        camera.pitch = newPitch
        camera.heading = newRoll
        
        UIView.animateWithDuration(0.001, animations: {
            self.map.camera = camera
        })
    }
}