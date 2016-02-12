//
//  EXTRollGestureRecognizer.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 14/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class EXTRollGestureRecognizer: UIGestureRecognizer {
    private let detector:EXTInteractionDetector
    
    var rollThreshold:Float
    var currentRoll:Float
    
    override init(target: AnyObject?, action: Selector) {
        detector = EXTInteractionDetector(dataCache: SensorProcessor.dataCache)
        rollThreshold = 0.0
        currentRoll = 0.0
        super.init(target: target, action: action)
        
        detector.subscribe(.DuringMetrics) { (data) -> Void in
            self.currentRoll = self.detector.currentRoll
            if fabs(self.currentRoll) > self.rollThreshold {
                self.state = .Changed
            }
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
        state = .Cancelled
    }
    
    override func canBePreventedByGestureRecognizer(preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func canPreventGestureRecognizer(preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}