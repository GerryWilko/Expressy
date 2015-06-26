//
//  SensorController.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 26/06/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import WatchKit
import CoreMotion

class SensorController: WKInterfaceController {
    @IBOutlet var accXLbl: WKInterfaceLabel!
    @IBOutlet var accYLbl: WKInterfaceLabel!
    @IBOutlet var accZLbl: WKInterfaceLabel!
    @IBOutlet var gyroXLbl: WKInterfaceLabel!
    @IBOutlet var gyroYLbl: WKInterfaceLabel!
    @IBOutlet var gyroZLbl: WKInterfaceLabel!
    
    private let motionManager:CMMotionManager
    
    override init() {
        motionManager = CMMotionManager()
        super.init()
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    override func willActivate() {
        super.willActivate()
        
        if (motionManager.accelerometerAvailable) {
            let handler:CMAccelerometerHandler = {(data: CMAccelerometerData?, error: NSError?) -> Void in
                self.accXLbl.setText(String(format: "%.2f", data!.acceleration.x))
                self.accYLbl.setText(String(format: "%.2f", data!.acceleration.y))
                self.accZLbl.setText(String(format: "%.2f", data!.acceleration.z))
            }
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
        } else {
            self.accXLbl.setText("not available")
            self.accYLbl.setText("not available")
            self.accZLbl.setText("not available")
        }
        
        if (motionManager.gyroAvailable) {
            let handler:CMGyroHandler = {(data: CMGyroData?, error: NSError?) -> Void in
                self.gyroXLbl.setText(String(format: "%.2f", data!.rotationRate.x))
                self.gyroYLbl.setText(String(format: "%.2f", data!.rotationRate.y))
                self.gyroZLbl.setText(String(format: "%.2f", data!.rotationRate.z))
            }
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
        } else {
            self.gyroXLbl.setText("not available")
            self.gyroYLbl.setText("not available")
            self.gyroZLbl.setText("not available")
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
}