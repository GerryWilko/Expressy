//
//  ETPaintGestureView.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 03/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation

class ETPaintGestureView: DAScratchPadView {
    private let detector:InteractionDetector
    private var initialWidth:CGFloat!
    
    required init?(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: SensorProcessor.dataCache)
        super.init(coder: aDecoder)
        detector.startDetection()
    }
    
    deinit {
        detector.stopDetection()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        initialWidth = drawWidth
        detector.touchDown()
        detector.subscribe(EventType.Metrics, callback: metricCallback)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        detector.touchUp()
        detector.clearSubscriptions()
    }
    
    private func metricCallback(data:Float?) {
        drawWidth = initialWidth + CGFloat(detector.currentRotation / 5.00)
    }
}