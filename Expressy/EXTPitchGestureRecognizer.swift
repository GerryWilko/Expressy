//
//  EXTPitchGestureRecognizer.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 14/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class EXTPitchGestureRecognizer: UIGestureRecognizer {
    fileprivate let detector:EXTInteractionDetector
    
    var pitchThreshold:Float
    var currentPitch:Float
    
    override init(target: Any?, action: Selector?) {
        detector = EXTInteractionDetector(dataCache: SensorProcessor.dataCache)
        pitchThreshold = 0.0
        currentPitch = 0.0
        super.init(target: target, action: action)
        
        detector.subscribe(.duringMetrics) { (data) -> Void in
            self.currentPitch = self.detector.currentPitch
            if fabs(self.currentPitch) > self.pitchThreshold {
                self.state = .changed
            }
        }
        
        detector.startDetection()
    }
    
    deinit {
        detector.stopDetection()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        detector.touchDown()
        state = .began
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
