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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ScrollDemoVC: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate {
    let detector:EXTInteractionDetector
    
    fileprivate var startRecordTime:TimeInterval?
    fileprivate var scrollPace:CGFloat!
    
    required init?(coder aDecoder: NSCoder) {
        detector = EXTInteractionDetector(dataCache: SensorProcessor.dataCache)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textView = self.view as! UITextView
        textView.text = LoremIpsum.paragraphs(withNumber: 10000)
        textView.font = textView.font?.withSize(20)
        
        textView.delegate = self
        
        textView.textContainerInset = UIEdgeInsetsMake(0, 50, 0, 50)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        detector.startDetection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detector.stopDetection()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        detector.clearSubscriptions()
        detector.touchDown()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let textView = self.view as! UITextView
        detector.touchUp()
        scrollPace = velocity.y * 10.0
        detector.subscribe(.metrics) { (data) -> Void in
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
    
    @IBAction func RecordBtn(_ sender: UIBarButtonItem) {
        if let startTime = startRecordTime {
            sender.image = UIImage(named: "RecordIcon")
            startRecordTime = nil
            
            let csv = CSVBuilder(files: ["scrollDemo-sensordata.csv" : SensorData.headerLine()])
            
            EvalUtils.logDataBetweenTimes(startTime, endTime: Date.timeIntervalSinceReferenceDate, csv: csv, file: "scrollDemo-sensordata.csv")
            
            emailCSV(csv)
            SensorCache.resetLimit()
        } else {
            sender.image = UIImage(named: "PauseIcon")
            startRecordTime = Date.timeIntervalSinceReferenceDate
            SensorCache.setRecordLimit()
        }
    }
    
    func emailCSV(_ csv:CSVBuilder) {
        if(MFMailComposeViewController.canSendMail()){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            mail.setSubject("Scroll Demo sensor data")
            
            for file in csv.files {
                if let data = file.1.data(using: String.Encoding.utf8) {
                    mail.addAttachmentData(data, mimeType: "text/csv", fileName: file.0)
                } else {
                    let alert = UIAlertController(title: "Error exporting CSV", message: "Unable to read CSV file.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
            }
            
            mail.setToRecipients(["gerrywilko@googlemail.com"])
            present(mail, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error exporting CSV", message: "Your device cannot send emails.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
