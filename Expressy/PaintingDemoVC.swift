//
//  PaintingDemoVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 03/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import DAScratchPad
import SVProgressHUD
import MessageUI

class PaintingDemoVC: UIViewController, MFMailComposeViewControllerDelegate {
    fileprivate let startingStrokeWidth:CGFloat = 30.0
    fileprivate let minDrawWidth:CGFloat = 5.00
    
    fileprivate var initialWidth:CGFloat!
    fileprivate var startRecordTime:TimeInterval?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paintForce = EXTForceGestureRecognizer(target: self, action: #selector(PaintingDemoVC.paintForce(_:)), event: .allPress)
        let paintRoll = EXTRollGestureRecognizer(target: self, action: #selector(PaintingDemoVC.paintRoll(_:)))
        let paintFlick = EXTFlickGestureRecognizer(target: self, action: #selector(PaintingDemoVC.paintFlick(_:)))
        
        paintForce.cancelsTouchesInView = false
        paintRoll.cancelsTouchesInView = false
        paintFlick.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(paintForce)
        self.view.addGestureRecognizer(paintRoll)
        self.view.addGestureRecognizer(paintFlick)
    }
    
    @IBAction func etToggle(_ sender: AnyObject) {
        self.view.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.isEnabled = !recognizer.isEnabled
        })
        SVProgressHUD.show(UIImage(named: "ExpressyIcon"), status: self.view.gestureRecognizers!.first!.isEnabled ? "Expressive Touch Enabled" : "Expressive Touch Disabled")
    }
    
    func paintForce(_ recognizer:EXTForceGestureRecognizer) {
        let paintView = self.view as! DAScratchPadView
        switch recognizer.state {
        case .began:
            paintView.drawWidth = startingStrokeWidth * CGFloat(recognizer.tapForce)
            paintView.drawWidth = paintView.drawWidth > minDrawWidth ? paintView.drawWidth : minDrawWidth
            initialWidth = paintView.drawWidth
        default:
            break
        }
    }
    
    func paintRoll(_ recognizer:EXTRollGestureRecognizer) {
        let paintView = self.view as! DAScratchPadView
        switch recognizer.state {
        case .changed:
            paintView.drawWidth = initialWidth + CGFloat(recognizer.currentRoll / 2.00)
            paintView.drawWidth = paintView.drawWidth > minDrawWidth ? paintView.drawWidth : minDrawWidth
        default:
            break
        }
    }
    
    func paintFlick(_ recognizer:EXTFlickGestureRecognizer) {
        //let paintView = self.view as! DAScratchPadView
        switch recognizer.state {
        case .ended:
            break
        default:
            break
        }
    }
    
    @IBAction func clear(_ sender: AnyObject) {
        let paintView = self.view as! DAScratchPadView
        paintView.clear(to: UIColor.white)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "colorPickerSegue" {
            let destinationVC = segue.destination as! UINavigationController
            let colorPicker = destinationVC.topViewController as! PaintingDemoColorPickerVC
            colorPicker.paintView = self.view as! DAScratchPadView
        }
    }
    
    @IBAction func unwindToPaintingDemo(_ segue: UIStoryboardSegue) {}
    
    @IBAction func RecordBtn(_ sender: UIBarButtonItem) {
        if let startTime = startRecordTime {
            sender.image = UIImage(named: "RecordIcon")
            startRecordTime = nil
            
            let csv = CSVBuilder(files: ["paintingDemo-sensordata.csv" : SensorData.headerLine()])
            
            EvalUtils.logDataBetweenTimes(startTime, endTime: Date.timeIntervalSinceReferenceDate, csv: csv, file: "paintingDemo-sensordata.csv")
            
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
            
            mail.setSubject("Painting Demo sensor data")
            
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
