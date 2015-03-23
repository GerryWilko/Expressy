//
//  ETDetectorViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 03/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import MessageUI

class ETDetectorViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func exportData(sender: AnyObject) {
        var csvString = NSMutableString()
        csvString.appendString("Time,ax,ay,az,gx,gy,gz,mx,my,mz,gravx,gravy,gravz,yaw,pitch,roll,Touch,Touch Force")
        
        let dataCache = WaxProcessor.getProcessor().dataCache
        
        for i in 0..<dataCache.count() {
            let data = dataCache[i]
            let ypr = data.getYawPitchRoll()
            csvString.appendString("\n\(data.time),\(data.acc.x),\(data.acc.y),\(data.acc.z),\(data.gyro.x),\(data.gyro.y),\(data.gyro.z),\(data.mag.x),\(data.mag.y),\(data.mag.z),\(data.grav.x),\(data.grav.y),\(data.grav.z),\(ypr.yaw),\(ypr.pitch),\(ypr.roll),\(data.touch),\(data.touchForce)")
        }
        
        let fileManager = (NSFileManager.defaultManager())
        let directorys : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        
        if ((directorys) != nil) {
            
            let directories:[String] = directorys!
            let dictionary = directories[0]
            let datapath = dictionary.stringByAppendingPathComponent("data.csv")
            
            println("\(datapath)")
            
            csvString.writeToFile(datapath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
            
            var myMail:MFMailComposeViewController!
            
            if(MFMailComposeViewController.canSendMail()){
                
                myMail = MFMailComposeViewController()
                myMail.mailComposeDelegate = self
                
                myMail.setSubject("Expressive Touch export")
                
                var sentfrom = "Expressive Touch"
                myMail.setMessageBody(sentfrom, isHTML: true)
                
                var testData: NSData = NSData(contentsOfFile: datapath)!
                
                myMail.addAttachmentData(testData, mimeType: "text/csv", fileName: "data.csv")
                
                self.presentViewController(myMail, animated: true, completion: nil)
            }
            else {
                var alert = UIAlertController(title: "Alert", message: "Your device cannot send emails", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else {
            println("File system error!")
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        let interactionView = self.view as! InteractionView
        interactionView.detector.stopDetection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}