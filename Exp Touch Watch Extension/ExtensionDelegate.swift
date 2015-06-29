//
//  ExtensionDelegate.swift
//  Exp Touch Watch Extension
//
//  Created by Gerard Wilkinson on 26/06/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import WatchKit
import CoreMotion
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    private static var motionManager = CMMotionManager()
    private var lastAcc:CMAccelerometerData?
    private var lastGyro:CMGyroData?
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if (ExtensionDelegate.motionManager.accelerometerAvailable) {
            let handler:CMAccelerometerHandler = {(data: CMAccelerometerData?, error: NSError?) -> Void in
                if let accData = data {
                    if let gyroData =  self.lastGyro {
                        WCSession.defaultSession().sendMessage(["accData": accData, "gyroData": gyroData], replyHandler: nil, errorHandler: nil)
                        self.lastGyro = nil
                    } else {
                        self.lastAcc = accData
                    }
                }
            }
            ExtensionDelegate.motionManager.accelerometerUpdateInterval = 0.1
            ExtensionDelegate.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
        }
        
        if (ExtensionDelegate.motionManager.gyroAvailable) {
            let handler:CMGyroHandler = {(data: CMGyroData?, error: NSError?) -> Void in
                if let gyroData = data {
                    if let accData = self.lastAcc {
                        WCSession.defaultSession().sendMessage(["accData": accData, "gyroData": gyroData], replyHandler: nil, errorHandler: nil)
                        self.lastAcc = nil
                    } else {
                        self.lastGyro = gyroData
                    }
                }
            }
            ExtensionDelegate.motionManager.gyroUpdateInterval = 0.1
            ExtensionDelegate.motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
        }
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}
