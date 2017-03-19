//
//  EXTForceGestureRecognizer.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 14/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class EXTForceGestureRecognizer: UIGestureRecognizer {
    fileprivate let detector:EXTInteractionDetector
    
    var tapForce:Float
    
    init(target: AnyObject?, action: Selector, event:EXTForceEvent) {
        detector = EXTInteractionDetector(dataCache: SensorProcessor.dataCache)
        tapForce = 0.0
        super.init(target: target, action: action)
        
        var interactionEvent:EXTEvent
        
        switch (event) {
        case .allPress:
            interactionEvent = .allPress
        case .soft:
            interactionEvent = .softPress
        case .medium:
            interactionEvent = .mediumPress
        case .hard:
            interactionEvent = .hardPress
        }
        
        detector.subscribe(interactionEvent) { (data) -> Void in
            self.tapForce = data!
            self.state = .began
        }
        
        detector.startDetection()
    }
    
    deinit {
        detector.stopDetection()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        detector.touchDown()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        detector.touchUp()
        state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        detector.touchCancelled()
        state = .cancelled
    }
    
    override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

enum EXTForceEvent {
    case allPress, soft, medium, hard
}
