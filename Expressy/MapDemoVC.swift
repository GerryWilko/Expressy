//
//  MapDemoVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 25/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import MapKit
import SVProgressHUD
import MessageUI

class MapDemoVC: UIViewController, MFMailComposeViewControllerDelegate {
    fileprivate let pitchBound:CGFloat = 50.0
    
    fileprivate var startRecordTime:TimeInterval?
    fileprivate var touchHeading:CLLocationDirection!
    fileprivate var touchPitch:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let map = self.view as! MKMapView
        
        map.showsBuildings = true
        
        let userCoordinate = CLLocationCoordinate2D(latitude: 51.5033, longitude: -0.11967)
        let eyeCoordinate = CLLocationCoordinate2D(latitude: 51.5033, longitude: -0.11967)
        let mapCamera = MKMapCamera(lookingAtCenter: userCoordinate, fromEyeCoordinate: eyeCoordinate, eyeAltitude: 400.0)
        map.setCamera(mapCamera, animated: true)
        
        touchHeading = map.camera.heading
        touchPitch = map.camera.pitch
        
        let rollRecognizer = EXTRollGestureRecognizer(target: self, action: #selector(MapDemoVC.rollUpdated(_:)))
        let pitchRecognizer = EXTPitchGestureRecognizer(target: self, action: #selector(MapDemoVC.pitchUpdated(_:)))
        
        rollRecognizer.cancelsTouchesInView = false
        pitchRecognizer.cancelsTouchesInView = false
        
        map.addGestureRecognizer(rollRecognizer)
        map.addGestureRecognizer(pitchRecognizer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchHeading = (view as! MKMapView).camera.heading
    }
    
    @IBAction func etToggle(_ sender: AnyObject) {
        self.view.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.isEnabled = !recognizer.isEnabled
        })
        SVProgressHUD.show(UIImage(named: "ExpressyIcon"), status: self.view.gestureRecognizers!.first!.isEnabled ? "Expressive Touch Enabled" : "Expressive Touch Disabled")
    }
    
    func rollUpdated(_ recognizer:EXTRollGestureRecognizer) {
        let map = view as! MKMapView
        if recognizer.state == .began {
            touchHeading = map.camera.heading
        } else if recognizer.state == .changed {
            let newRoll = touchHeading + CLLocationDirection(recognizer.currentRoll)
            
            let camera = map.camera.copy() as! MKMapCamera
            camera.heading = newRoll
            
            map.camera = camera
        }
    }
    
    func pitchUpdated(_ recognizer:EXTPitchGestureRecognizer) {
        let map = view as! MKMapView
        if recognizer.state == .began {
            touchPitch = map.camera.pitch
        } else if recognizer.state == .changed {
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
    
    @IBAction func RecordBtn(_ sender: UIBarButtonItem) {
        if let startTime = startRecordTime {
            sender.image = UIImage(named: "RecordIcon")
            startRecordTime = nil
            
            let csv = CSVBuilder(files: ["mapDemo-sensordata.csv" : SensorData.headerLine()])
            
            EvalUtils.logDataBetweenTimes(startTime, endTime: Date.timeIntervalSinceReferenceDate, csv: csv, file: "mapDemo-sensordata.csv")
            
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
            
            mail.setSubject("Map Demo sensor data")
            
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
        dismiss(animated: true, completion: nil)
    }
}
