//
//  ControlsDemoVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 22/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import MDRadialProgress
import MessageUI

class ControlsDemoVC: UIViewController, MFMailComposeViewControllerDelegate {
    private var touchImageTransform:CGAffineTransform!
    private var touchProgress:UInt
    
    private var startRecordTime:NSTimeInterval?
    private var rotationRecognizer:UIRotationGestureRecognizer!
    private var rollRecognizer:EXTRollGestureRecognizer!
    
    @IBOutlet weak var progressView: MDRadialProgressView!
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        touchProgress = 0
        
        super.init(coder: aDecoder)
        
        rotationRecognizer = UIRotationGestureRecognizer(target: self, action: Selector("imageRotated:"))
        rollRecognizer = EXTRollGestureRecognizer(target: self, action: Selector("imageEXTRoll:"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.addGestureRecognizer(EXTRollGestureRecognizer(target: self, action: Selector("progressRoll:")))
        progressView.progressCounter = 0
        progressView.progressTotal = UInt(100)
        
        touchImageTransform = imageView.transform
        
        imageView.addGestureRecognizer(rollRecognizer)
    }
    
    func progressRoll(recognizer:EXTRollGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            touchProgress = progressView.progressCounter
        case .Changed:
            var newValue = Int(touchProgress) + Int(recognizer.currentRoll)
            
            if newValue > 100 {
                newValue = 100
            } else if newValue < 0 {
                newValue = 0
            }
            
            progressView.progressCounter = UInt(newValue)
        default:
            break
        }
    }
    
    @IBAction func imageEXTSwitch(sender: UISwitch) {
        if sender.on {
            imageView.removeGestureRecognizer(rotationRecognizer)
            imageView.addGestureRecognizer(rollRecognizer)
        } else {
            imageView.removeGestureRecognizer(rollRecognizer)
            imageView.addGestureRecognizer(rotationRecognizer)
        }
    }
    
    func imageRotated(recognizer:UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            touchImageTransform = imageView.transform
        case .Changed:
            imageView.transform = CGAffineTransformRotate(touchImageTransform, recognizer.rotation)
        default:
            break
        }
    }
    
    func imageEXTRoll(recognizer:EXTRollGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            touchImageTransform = imageView.transform
        case .Changed:
            imageView.transform = CGAffineTransformRotate(touchImageTransform, CGFloat(recognizer.currentRoll) * CGFloat(M_PI / 180))
        default:
            break
        }
    }
    
    @IBAction func RecordBtn(sender: UIBarButtonItem) {
        if let startTime = startRecordTime {
            sender.image = UIImage(named: "RecordIcon")
            startRecordTime = nil
            
            let csv = CSVBuilder(files: ["controlsDemo-sensordata.csv" : SensorData.headerLine()])
            
            EvalUtils.logDataBetweenTimes(startTime, endTime: NSDate.timeIntervalSinceReferenceDate(), csv: csv, file: "controlsDemo-sensordata.csv")
            
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
            
            mail.setSubject("Controls Demo sensor data")
            
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