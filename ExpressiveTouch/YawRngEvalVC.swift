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
    private var startTime:NSTimeInterval!
    
    private let detector:InteractionDetector
    private let csvBuilder:CSVBuilder
    
    @IBOutlet weak var dominantHand: UISegmentedControl!
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressWheel: UIActivityIndicatorView!
    
    required init(coder aDecoder: NSCoder) {
        messageStack = [
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Swap the sensor onto your left wrist.\nThen press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now yaw as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Evaluation Complete. Thank you."
        ]
        
        maxValue = 0.0
        minValue = 0.0
        recording = false
        
        detector = InteractionDetector(dataCache: SensorProcessor.getProcessor().dataCache)
        csvBuilder = CSVBuilder(fileNames: ["yawRange.csv","yawData.csv"], headerLines: ["Dominant Hand,Wrist,Max Angle,Min Angle", SensorData.headerLine()])
        super.init(coder: aDecoder)
        detector.startDetection()
    }
    
    override func viewDidLoad() {
        self.performSegueWithIdentifier("yawRngInstructions", sender: self)
        SensorProcessor.getProcessor().dataCache.subscribe(dataCallback)
        startTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    override func viewDidDisappear(animated: Bool) {
        detector.stopDetection()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
        
        if (!messageStack.isEmpty && dominantHand.selectedSegmentIndex != UISegmentedControlNoSegment) {
            progressWheel.startAnimating()
            recording = true
            instructionLbl.text = messageStack[0]
            messageStack.removeAtIndex(0)
            progressBar.setProgress(Float(Float(41 - messageStack.count) / 41.0), animated: true)
        }
    }
    
    func dataCallback(data:SensorData) {
        if (recording) {
            if (self.maxValue < data.getYawPitchRoll().yaw) {
                self.maxValue = data.getYawPitchRoll().yaw
            }
            
            if (self.minValue > data.getYawPitchRoll().yaw) {
                self.minValue = data.getYawPitchRoll().yaw
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
        
        if (!messageStack.isEmpty && dominantHand.selectedSegmentIndex != UISegmentedControlNoSegment) {
            progressWheel.stopAnimating()
            recording = false
            
            let dh = dominantHand.selectedSegmentIndex == 0 ? "Left" : "Right"
            
            if (messageStack.count > 20) {
                csvBuilder.appendRow("\(dh),Right,\(maxValue),\(minValue)", index: 0)
                maxValue = 0.0
                minValue = 0.0
            } else if (messageStack.count > 0) {
                csvBuilder.appendRow("\(dh),Left,\(maxValue),\(minValue)", index: 0)
                maxValue = 0.0
                minValue = 0.0
            }
            
            instructionLbl.text = messageStack[0]
            messageStack.removeAtIndex(0)
            progressBar.setProgress(Float(Float(41 - messageStack.count) / 41.0), animated: true)
            
            if (messageStack.isEmpty) {
                SensorProcessor.getProcessor().dataCache.clearSubscriptions()
                EvalUtils.logDataBetweenTimes(startTime, endTime: NSDate.timeIntervalSinceReferenceDate(), csv: csvBuilder)
                csvBuilder.emailCSV(self, subject: "Yaw Range Evaluation")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "yawRngInstructions" {
            let destVC = segue.destinationViewController as! EvalInstructionsVC
            destVC.videoPath = "Yaw Range Demo"
        }
    }
    
    @IBAction func next(sender: AnyObject) {
    }
}