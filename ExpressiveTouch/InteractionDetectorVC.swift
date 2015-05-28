//
//  InteractionDetectorVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 03/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class InteractionDetectorVC: UIViewController {
    private let detector:InteractionDetector
    
    @IBOutlet weak var forceLbl: UILabel!
    @IBOutlet weak var rotationLbl: UILabel!
    @IBOutlet weak var pitchLbl: UILabel!
    @IBOutlet weak var flickedSwitch: UISwitch!
    
    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: SensorProcessor.getProcessor().dataCache)
        detector.startDetection()
        
        super.init(coder: aDecoder)
        
        detector.subscribe(EventType.Metrics, callback: dataCallback)
        detector.subscribe(EventType.Flicked, callback: flickedCallback)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
        flickedSwitch.setOn(false, animated: true)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
    }
    
    private func dataCallback(data:Float!) {
        forceLbl.text = String(format: "%.2f", detector.currentForce)
        rotationLbl.text = String(format: "%.2f", detector.currentRotation)
        pitchLbl.text = String(format: "%.2f", detector.currentPitch)
    }
    
    private func flickedCallback(data:Float!) {
        self.flickedSwitch.setOn(true, animated: true)
    }
    
    @IBAction func exportData(sender: AnyObject) {
        let csv = CSVBuilder(fileNames: ["data.csv"], headerLines: [SensorData.headerLine()])
        
        let dataCache = SensorProcessor.getProcessor().dataCache
        
        for i in 0..<dataCache.count() {
            let data = dataCache[i]
            csv.appendRow(data.print(), index: 0)
        }
        
        csv.emailCSV(self, subject: "Interaction Data")
    }
    
    override func viewDidDisappear(animated: Bool) {
        detector.stopDetection()
    }
}