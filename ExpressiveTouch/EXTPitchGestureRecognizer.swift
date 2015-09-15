//
//  EXTPitchGestureRecognizer.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 14/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class EXTPitchGestureRecognizer: UIGestureRecognizer {
    private let detector:EXTInteractionDetector
    
    var currentPitch:Float
    
    override init(target: AnyObject?, action: Selector) {
        detector = EXTInteractionDetector(dataCache: SensorProcessor.dataCache)
        currentPitch = 0.0
        super.init(target: target, action: action)
        
        detector.subscribe(.DuringMetrics) { (data) -> Void in
            self.currentPitch = self.detector.currentPitch
            self.state = .Changed
        }
        
        detector.startDetection()
    }
    
    deinit {
        detector.stopDetection()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        detector.touchDown()
        state = .Began
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        detector.touchUp()
        state = .Ended
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
        detector.touchCancelled()
    }
}