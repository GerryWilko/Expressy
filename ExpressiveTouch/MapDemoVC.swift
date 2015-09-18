//
//  MapDemoVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 25/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import MapKit
import SVProgressHUD
import MessageUI

class MapDemoVC: UIViewController, MFMailComposeViewControllerDelegate {
    private let pitchBound:CGFloat = 50.0
    
    private var startRecordTime:NSTimeInterval?
    private var touchHeading:CLLocationDirection!
    private var touchPitch:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let map = self.view as! MKMapView
        
        map.showsBuildings = true
        
        let userCoordinate = CLLocationCoordinate2D(latitude: 51.5033, longitude: -0.11967)
        let eyeCoordinate = CLLocationCoordinate2D(latitude: 51.5033, longitude: -0.11967)
        let mapCamera = MKMapCamera(lookingAtCenterCoordinate: userCoordinate, fromEyeCoordinate: eyeCoordinate, eyeAltitude: 400.0)
        map.setCamera(mapCamera, animated: true)
        
        touchHeading = map.camera.heading
        touchPitch = map.camera.pitch
        
        let rollRecognizer = EXTRollGestureRecognizer(target: self, action: Selector("rollUpdated:"))
        let pitchRecognizer = EXTPitchGestureRecognizer(target: self, action: Selector("pitchUpdated:"))
        
        rollRecognizer.cancelsTouchesInView = false
        pitchRecognizer.cancelsTouchesInView = false
        
        map.addGestureRecognizer(rollRecognizer)
        map.addGestureRecognizer(pitchRecognizer)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        touchHeading = (view as! MKMapView).camera.heading
    }
    
    @IBAction func etToggle(sender: AnyObject) {
        self.view.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.enabled = !recognizer.enabled
        })
        SVProgressHUD.showImage(UIImage(named: "ExpressiveTouchIcon"), status: self.view.gestureRecognizers!.first!.enabled ? "Expressive Touch Enabled" : "Expressive Touch Disabled")
    }
    
    func rollUpdated(recognizer:EXTRollGestureRecognizer) {
        let map = view as! MKMapView
        if recognizer.state == .Began {
            touchHeading = map.camera.heading
        } else if recognizer.state == .Changed {
            let newRoll = touchHeading + CLLocationDirection(recognizer.currentRoll)
            
            let camera = map.camera.copy() as! MKMapCamera
            camera.heading = newRoll
            
            map.camera = camera
        }
    }
    
    func pitchUpdated(recognizer:EXTPitchGestureRecognizer) {
        let map = view as! MKMapView
        if recognizer.state == .Began {
            touchPitch = map.camera.pitch
        } else if recognizer.state == .Changed {
            var newPitch = touchPitch + CGFloat(-recognizer.currentPitch * 3)
            
            if (newPitch < 0) {
                newPitch = 0
            } else if (newPitch > pitchBound) {
                newPitch = pitchBound
            }
            
            let camera = map.camera.copy() as! MKMapCamera
            camera.pitch = newPitch
            
            map.camera = camera
        }
    }
    
    @IBAction func RecordBtn(sender: UIBarButtonItem) {
        if let startTime = startRecordTime {
            sender.image = UIImage(named: "RecordIcon")
            startRecordTime = nil
            
            let csv = CSVBuilder(files: ["mapDemo-sensordata.csv" : SensorData.headerLine()])
            
            EvalUtils.logDataBetweenTimes(startTime, endTime: NSDate.timeIntervalSinceReferenceDate(), csv: csv, file: "mapDemo-sensordata.csv")
            
            emailCSV(csv)
        } else {
            sender.image = UIImage(named: "PauseIcon")
            startRecordTime = NSDate.timeIntervalSinceReferenceDate()
        }
    }
    
    func emailCSV(csv:CSVBuilder) {
        if(MFMailComposeViewController.canSendMail()){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            mail.setSubject("Map Demo sensor data")
            
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
        dismissViewControllerAnimated(true, completion: nil)
    }
}