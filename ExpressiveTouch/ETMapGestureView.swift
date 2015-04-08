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
        detector.subscribe(EventType.Metrics, callback: metricCallback)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        MadgwickAHRSreset()
        touchPitch = map.camera.pitch
        touchHeading = map.camera.heading
        detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
    }
    
    func metricCallback() {
        var newPitch = touchPitch + CGFloat(detector.currentPitch)
        var newRoll = touchHeading + CLLocationDirection(detector.currentForce)
        
        if (newPitch < 0) {
            newPitch = 0
        } else if (newPitch > pitchBound) {
            newPitch = pitchBound
        }
        
        map.camera.pitch = newPitch
        map.camera.heading = newRoll
    }
}