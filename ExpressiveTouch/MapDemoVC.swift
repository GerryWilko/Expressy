//
//  MapDemoVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 25/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import MapKit

class MapDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let map = self.view as! MKMapView
        
        map.showsBuildings = true
        
        let userCoordinate = CLLocationCoordinate2D(latitude: 51.5033, longitude: -0.11967)
        let eyeCoordinate = CLLocationCoordinate2D(latitude: 51.5033, longitude: -0.11967)
        let mapCamera = MKMapCamera(lookingAtCenterCoordinate: userCoordinate, fromEyeCoordinate: eyeCoordinate, eyeAltitude: 400.0)
        map.setCamera(mapCamera, animated: true)
        let gr = MapGestureRecognizer()
        gr.map = map
        map.addGestureRecognizer(gr)
    }
    
    @IBAction func resetModel(sender: UIBarButtonItem) {
        MadgwickAHRSreset()
    }
}