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
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var viewDataBtn: UIBarButtonItem!
    
    private var recording:Bool
    private var timer:NSTimer
    private var startTime:NSTimeInterval
    
    required init(coder aDecoder: NSCoder) {
        recording = false
        timer = NSTimer()
        startTime = NSTimeInterval()
        super.init(coder: aDecoder)
    }
    
    @IBAction func recordPress(sender: UIButton) {
        if (recording) {
            timer.invalidate()
            recordBtn.setAttributedTitle(NSAttributedString(string: "Start Recording"), forState: UIControlState.Normal)
            WaxProcessor.getProcessor().stopRecording()
            viewDataBtn.enabled = true
        } else {
            startTime = NSDate.timeIntervalSinceReferenceDate()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true)
            recordBtn.setAttributedTitle(NSAttributedString(string: "Stop Recording"), forState: UIControlState.Normal)
            WaxProcessor.getProcessor().startRecording()
        }
        recording = !recording
    }
    
    @IBAction func viewData(sender: AnyObject) {
        GraphTabViewController.setLive(false)
        self.performSegueWithIdentifier("recordViewData", sender: sender)
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        var elapsedTime = currentTime - startTime
        
        let minutes = UInt(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        let seconds = UInt(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        let fraction = UInt(elapsedTime * 100)
        
        let strMinutes = minutes > 9 ? String(minutes) : "0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds) : "0" + String(seconds)
        let strFraction = fraction > 9 ? String(fraction) : "0" + String(fraction)
        
        timeLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
    }
    
    func tappedView() {
        WaxProcessor.getProcessor().tapped()
    }
    
    func pinchedView() {
        WaxProcessor.getProcessor().pinched()
    }
    
    func rotatedView() {
        WaxProcessor.getProcessor().rotated()
    }
    
    func swipedView() {
        WaxProcessor.getProcessor().swiped()
    }
    
    func pannedView() {
        WaxProcessor.getProcessor().panned()
    }
    
    func edgePanView() {
        WaxProcessor.getProcessor().edgePan()
    }
    
    func longPressView() {
        WaxProcessor.getProcessor().longPress()
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