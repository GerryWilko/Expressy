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
    fileprivate var touchImageTransform:CGAffineTransform!
    fileprivate var touchProgress:UInt
    
    fileprivate var startRecordTime:TimeInterval?
    fileprivate var rotationRecognizer:UIRotationGestureRecognizer!
    fileprivate var rollRecognizer:EXTRollGestureRecognizer!
    
    @IBOutlet weak var progressView: MDRadialProgressView!
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        touchProgress = 0
        
        super.init(coder: aDecoder)
        
        rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(ControlsDemoVC.imageRotated(_:)))
        rollRecognizer = EXTRollGestureRecognizer(target: self, action: #selector(ControlsDemoVC.imageEXTRoll(_:)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.addGestureRecognizer(EXTRollGestureRecognizer(target: self, action: #selector(ControlsDemoVC.progressRoll(_:))))
        progressView.progressCounter = 0
        progressView.progressTotal = UInt(100)
        
        touchImageTransform = imageView.transform
        
        imageView.addGestureRecognizer(rollRecognizer)
    }
    
    func progressRoll(_ recognizer:EXTRollGestureRecognizer) {
        switch recognizer.state {
        case .began:
            touchProgress = progressView.progressCounter
        case .changed:
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
    
    @IBAction func imageEXTSwitch(_ sender: UISwitch) {
        if sender.isOn {
            imageView.removeGestureRecognizer(rotationRecognizer)
            imageView.addGestureRecognizer(rollRecognizer)
        } else {
            imageView.removeGestureRecognizer(rollRecognizer)
            imageView.addGestureRecognizer(rotationRecognizer)
        }
    }
    
    func imageRotated(_ recognizer:UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .began:
            touchImageTransform = imageView.transform
        case .changed:
            imageView.transform = touchImageTransform.rotated(by: recognizer.rotation)
        default:
            break
        }
    }
    
    func imageEXTRoll(_ recognizer:EXTRollGestureRecognizer) {
        switch recognizer.state {
        case .began:
            touchImageTransform = imageView.transform
        case .changed:
            imageView.transform = touchImageTransform.rotated(by: CGFloat(recognizer.currentRoll) * CGFloat(M_PI / 180))
        default:
            break
        }
    }
    
    @IBAction func RecordBtn(_ sender: UIBarButtonItem) {
        if let startTime = startRecordTime {
            sender.image = UIImage(named: "RecordIcon")
            startRecordTime = nil
            
            let csv = CSVBuilder(files: ["controlsDemo-sensordata.csv" : SensorData.headerLine()])
            
            EvalUtils.logDataBetweenTimes(startTime, endTime: Date.timeIntervalSinceReferenceDate, csv: csv, file: "controlsDemo-sensordata.csv")
            
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
            
            mail.setSubject("Controls Demo sensor data")
            
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
