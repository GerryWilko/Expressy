//
//  ScrollDemoVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 04/09/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import MessageUI
import LoremIpsum

class ScrollDemoVC: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate {
    let detector:EXTInteractionDetector
    
    private var startRecordTime:NSTimeInterval?
    private var scrollPace:CGFloat!
    
    required init?(coder aDecoder: NSCoder) {
        detector = EXTInteractionDetector(dataCache: SensorProcessor.dataCache)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textView = self.view as! UITextView
        textView.text = LoremIpsum.paragraphsWithNumber(10000)
        textView.font = textView.font?.fontWithSize(20)
        
        textView.delegate = self
        
        textView.textContainerInset = UIEdgeInsetsMake(0, 50, 0, 50)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        detector.startDetection()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        detector.stopDetection()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        detector.clearSubscriptions()
        detector.touchDown()
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let textView = self.view as! UITextView
        detector.touchUp()
        scrollPace = velocity.y * 10.0
        detector.subscribe(.Metrics) { (data) -> Void in
            self.scrollPace! += CGFloat(self.detector.currentRoll)
            if (velocity.y > 0.0)
            {
                self.scrollPace = self.scrollPace < 0.0 ? 0.0 : self.scrollPace
            } else {
                self.scrollPace = self.scrollPace > 0.0 ? 0.0 : self.scrollPace
            }
            textView.setContentOffset(CGPoint(x: textView.contentOffset.x, y: textView.contentOffset.y + self.scrollPace), animated: true)
        }
    }
    
    @IBAction func RecordBtn(sender: UIBarButtonItem) {
        if let startTime = startRecordTime {
            sender.image = UIImage(named: "RecordIcon")
            startRecordTime = nil
            
            let csv = CSVBuilder(files: ["scrollDemo-sensordata.csv" : SensorData.headerLine()])
            
            EvalUtils.logDataBetweenTimes(startTime, endTime: NSDate.timeIntervalSinceReferenceDate(), csv: csv, file: "scrollDemo-sensordata.csv")
            
            emailCSV(csv)
            SensorCache.resetLimit()
        } else {
            sender.image = UIImage(named: "PauseIcon")
            startRecordTime = NSDate.timeIntervalSinceReferenceDate()
            SensorCache.setRecordLimit()
        }
    }
    
    func emailCSV(csv:CSVBuilder) {
        if(MFMailComposeViewController.canSendMail()){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            mail.setSubject("Scroll Demo sensor data")
            
            for file in csv.files {
                if let data = file.1.dataUsingEncoding(NSUTF8StringEncoding) {
                    mail.addAttachmentData(data, mimeType: "text/csv", fileName: file.0)
                } else {
                    let alert = UIAlertController(title: "Error exporting CSV", message: "Unable to read CSV file.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    presentViewController(alert, animated: true, completion: nil)
                }
            }
            
            mail.setToRecipients(["gerrywilko@googlemail.com"])
            presentViewController(mail, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error exporting CSV", message: "Your device cannot send emails.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}