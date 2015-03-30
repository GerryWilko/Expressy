//
//  ETMapView.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 18/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import MapKit

class ETMapView: MKMapView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.showsBuildings = true
        
        let userCoordinate = CLLocationCoordinate2D(latitude: 51.5033, longitude: -0.11967)
        let eyeCoordinate = CLLocationCoordinate2D(latitude: 51.5033, longitude: -0.11967)
        let mapCamera = MKMapCamera(lookingAtCenterCoordinate: userCoordinate, fromEyeCoordinate: eyeCoordinate, eyeAltitude: 400.0)
        self.setCamera(mapCamera, animated: true)
        let gr = MapGestureRecognizer()
        gr.map = self
        self.addGestureRecognizer(gr)
    }
}