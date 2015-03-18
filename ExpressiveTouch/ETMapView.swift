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
    var timer:NSTimer!

    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: WaxProcessor.getProcessor().dataCache)
        detector.startDetection()
        super.init(coder: aDecoder)
        
        self.mapType = MKMapType.Hybrid
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!detector.touchDown) {
            detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("interactionCallback:"), userInfo: nil, repeats: true)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (detector.touchDown) {
            detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
        }
    }
    
    @objc func interactionCallback(timer:NSTimer) {
        let data = WaxProcessor.getProcessor().dataCache.getForTime(NSDate.timeIntervalSinceReferenceDate()).getYawPitchRoll()
        
        self.camera.pitch = CGFloat(data.pitch * -1.0)
        self.camera.heading = CLLocationDirection(data.roll)
    }
}