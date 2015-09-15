//
//  EXTFlickGestureRecognizer.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 15/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class EXTFlickGestureRecognizer: UIGestureRecognizer {
    private let detector:EXTInteractionDetector
    
    var flickForce:Float
    var flicked:Bool
    
    override init(target: AnyObject?, action: Selector) {
        detector = EXTInteractionDetector(dataCache: SensorProcessor.dataCache)
        flickForce = 0.0
        flicked = false
        super.init(target: target, action: action)
        
        detector.subscribe(.Flick) { (data) -> Void in
            self.flickForce = data!
            self.flicked = true
            self.state = .Ended
        }
        
        detector.subscribe(.NoFlick) { (data) -> Void in
            self.flickForce = data!
            self.state = .Ended
        }
        
        detector.startDetection()
    }
    
    deinit {
        detector.stopDetection()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        detector.touchDown()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        detector.touchUp()
        flicked = false
        state = .Began
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
        detector.touchCancelled()
    }
}