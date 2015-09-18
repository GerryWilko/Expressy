//
//  EXTForceGestureRecognizer.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 14/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class EXTForceGestureRecognizer: UIGestureRecognizer {
    private let detector:EXTInteractionDetector
    
    var tapForce:Float
    
    init(target: AnyObject?, action: Selector, event:EXTForceEvent) {
        detector = EXTInteractionDetector(dataCache: SensorProcessor.dataCache)
        tapForce = 0.0
        super.init(target: target, action: action)
        
        var interactionEvent:EXTEvent
        
        switch (event) {
        case .AllPress:
            interactionEvent = .AllPress
        case .Soft:
            interactionEvent = .SoftPress
        case .Medium:
            interactionEvent = .MediumPress
        case .Hard:
            interactionEvent = .HardPress
        }
        
        detector.subscribe(interactionEvent) { (data) -> Void in
            self.tapForce = data!
            self.state = .Began
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

enum EXTForceEvent {
    case AllPress, Soft, Medium, Hard
}