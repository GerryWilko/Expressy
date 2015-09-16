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

class MapDemoVC: UIViewController {
    private let pitchBound:CGFloat = 50.0
    
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
}