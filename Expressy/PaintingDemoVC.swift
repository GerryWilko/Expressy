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
    private let startingStrokeWidth:CGFloat = 30.0
    private let minDrawWidth:CGFloat = 5.00
    
    private var initialWidth:CGFloat!
    private var startRecordTime:NSTimeInterval?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paintForce = EXTForceGestureRecognizer(target: self, action: Selector("paintForce:"), event: .AllPress)
        let paintRoll = EXTRollGestureRecognizer(target: self, action: Selector("paintRoll:"))
        let paintFlick = EXTFlickGestureRecognizer(target: self, action: Selector("paintFlick:"))
        
        paintForce.cancelsTouchesInView = false
        paintRoll.cancelsTouchesInView = false
        paintFlick.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(paintForce)
        self.view.addGestureRecognizer(paintRoll)
        self.view.addGestureRecognizer(paintFlick)
    }
    
    @IBAction func etToggle(sender: AnyObject) {
        self.view.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.enabled = !recognizer.enabled
        })
        SVProgressHUD.showImage(UIImage(named: "ExpressyIcon"), status: self.view.gestureRecognizers!.first!.enabled ? "Expressive Touch Enabled" : "Expressive Touch Disabled")
    }
    
    func paintForce(recognizer:EXTForceGestureRecognizer) {
        let paintView = self.view as! DAScratchPadView
        switch recognizer.state {
        case .Began:
            paintView.drawWidth = startingStrokeWidth * CGFloat(recognizer.tapForce)
            paintView.drawWidth = paintView.drawWidth > minDrawWidth ? paintView.drawWidth : minDrawWidth
            initialWidth = paintView.drawWidth
        default:
            break
        }
    }
    
    func paintRoll(recognizer:EXTRollGestureRecognizer) {
        let paintView = self.view as! DAScratchPadView
        switch recognizer.state {
        case .Changed:
            paintView.drawWidth = initialWidth + CGFloat(recognizer.currentRoll / 2.00)
            paintView.drawWidth = paintView.drawWidth > minDrawWidth ? paintView.drawWidth : minDrawWidth
        default:
            break
        }
    }
    
    func paintFlick(recognizer:EXTFlickGestureRecognizer) {
        //let paintView = self.view as! DAScratchPadView
        switch recognizer.state {
        case .Ended:
            break
        default:
            break
        }
    }
    
    @IBAction func clear(sender: AnyObject) {
        let paintView = self.view as! DAScratchPadView
        paintView.clearToColor(UIColor.whiteColor())
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "colorPickerSegue" {
            let destinationVC = segue.destinationViewController as! UINavigationController
            let colorPicker = destinationVC.topViewController as! PaintingDemoColorPickerVC
            colorPicker.paintView = self.view as! DAScratchPadView
        }
    }
    
    @IBAction func unwindToPaintingDemo(segue: UIStoryboardSegue) {}
    
    @IBAction func RecordBtn(sender: UIBarButtonItem) {
        if let startTime = startRecordTime {
            sender.image = UIImage(named: "RecordIcon")
            startRecordTime = nil
            
            let csv = CSVBuilder(files: ["paintingDemo-sensordata.csv" : SensorData.headerLine()])
            
            EvalUtils.logDataBetweenTimes(startTime, endTime: NSDate.timeIntervalSinceReferenceDate(), csv: csv, file: "paintingDemo-sensordata.csv")
            
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
            
            mail.setSubject("Painting Demo sensor data")
            
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