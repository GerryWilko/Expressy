//
//  YawRngEvalVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 26/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class YawRngEvalVC: UIViewController {
    private var messageStack:[String]
    private var maxValue:Float
    private var minValue:Float
    private var recording:Bool
    
    private let csvBuilder:CSVBuilder
    
    @IBOutlet weak var dominantHand: UISegmentedControl!
    @IBOutlet weak var instructionLbl: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        messageStack = [
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Swap the sensor onto your left wrist.\nThen press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Evaluation Complete. Thank you."
        ]
        
        maxValue = 0.0
        minValue = 0.0
        recording = false
        
        csvBuilder = CSVBuilder(fileNames: ["yawRange.csv","yawData.csv"], headerLines: ["Dominant Hand,Wrist,Max Angle,Min Angle", "Time,ax,ay,az,gx,gy,gz,mx,my,mz,gravx,gravy,gravz,yaw,pitch,roll"])
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.performSegueWithIdentifier("yawRngInstructions", sender: self)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!messageStack.isEmpty && dominantHand.selectedSegmentIndex != UISegmentedControlNoSegment) {
            MadgwickAHRSreset()
            
            let dataCache = WaxProcessor.getProcessor().dataCache
            
            dataCache.subscribe(dataCallback)
            
            instructionLbl.text = messageStack[0]
            messageStack.removeAtIndex(0)
        }
    }
    
    func dataCallback(data:WaxData) {
        if (recording) {
            if (self.maxValue < data.getYawPitchRoll().yaw) {
                self.maxValue = data.getYawPitchRoll().yaw
            }
            
            if (self.minValue > data.getYawPitchRoll().yaw) {
                self.minValue = data.getYawPitchRoll().yaw
            }
        }
        
        let ypr = data.getYawPitchRoll()
        csvBuilder.appendRow("\(data.time),\(data.acc.x),\(data.acc.y),\(data.acc.z),\(data.gyro.x),\(data.gyro.y),\(data.gyro.z),\(data.mag.x),\(data.mag.y),\(data.mag.z),\(data.grav.x),\(data.grav.y),\(data.grav.z),\(ypr.yaw),\(ypr.pitch),\(ypr.roll)", index: 1)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!messageStack.isEmpty && dominantHand.selectedSegmentIndex != UISegmentedControlNoSegment) {
            WaxProcessor.getProcessor().dataCache.clearSubscriptions()
            let dh = dominantHand.selectedSegmentIndex == 0 ? "Left" : "Right"
            
            if (messageStack.count == 3) {
                csvBuilder.appendRow("\(dh),Right,\(maxValue),\(minValue)", index: 0)
                maxValue = 0.0
                minValue = 0.0
            } else if (messageStack.count == 1) {
                csvBuilder.appendRow("\(dh),Left,\(maxValue),\(minValue)", index: 0)
                maxValue = 0.0
                minValue = 0.0
            }
            
            instructionLbl.text = messageStack[0]
            messageStack.removeAtIndex(0)
            
            if (messageStack.isEmpty) {
                WaxProcessor.getProcessor().dataCache.clearSubscriptions()
                csvBuilder.emailCSV(self, subject: "Yaw Range Evaluation")
            }
        }
    }
}