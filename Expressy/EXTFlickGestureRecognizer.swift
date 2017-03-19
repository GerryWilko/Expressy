//
//  EXTFlickGestureRecognizer.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 15/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class EXTFlickGestureRecognizer: UIGestureRecognizer {
    fileprivate let detector:EXTInteractionDetector
    
    var flickForce:Float
    var flicked:Bool
    
    override init(target: Any?, action: Selector?) {
        detector = EXTInteractionDetector(dataCache: SensorProcessor.dataCache)
        flickForce = 0.0
        flicked = false
        super.init(target: target, action: action)
        
        detector.subscribe(.flick) { (data) -> Void in
            self.flickForce = data!
            self.flicked = true
            self.state = .ended
        }
        
        detector.subscribe(.noFlick) { (data) -> Void in
            self.flickForce = data!
            self.state = .ended
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
        flicked = false
        state = .began
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
