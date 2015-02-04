//
//  RecordViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 28/01/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class RecordViewController : UIViewController {
    @IBOutlet weak var timeLabel: UILabel!
    
    private var recording:Bool
    private var timer:NSTimer
    private var startTime:NSTimeInterval
    
    required init(coder aDecoder: NSCoder) {
        recording = false
        timer = NSTimer()
        startTime = NSTimeInterval()
        super.init()
    }
    
    @IBAction func recordPress(sender: UIButton) {
        if (recording) {
            timeLabel.text = "Start Recording"
            startTime = NSTimeInterval()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        } else {
            timeLabel.text = "Stop Recording"
            timer.invalidate()
        }
        recording = !recording
    }
    
    func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        var elapsedTime = currentTime - startTime
        
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        let fraction = UInt8(elapsedTime * 100)
        
        let strMinutes = minutes > 9 ? String(minutes) : "0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds) : "0" + String(seconds)
        let strFraction = fraction > 9 ? String(fraction) : "0" + String(fraction)
        
        timeLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
    }
    
    func tappedView() {
        var processor = WaxProcessor.getProcessor()
        
        var latestAcc = processor.accCache.get(processor.accCache.length())
        var latestGyro = processor.gyroCache.get(processor.accCache.length())
        var latestMag = processor.magCache.get(processor.accCache.length())
        
        latestAcc.touch = true
        latestGyro.touch = true
        latestAcc.touch = true
    }
    
    override func viewDidLoad() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tappedView"))
        self.view.userInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}