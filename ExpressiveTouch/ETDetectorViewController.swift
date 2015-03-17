//
//  ETDetectorViewController.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 03/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import MessageUI

class ETDetectorViewController: UIViewController {
    @IBOutlet weak var interactionView: InteractionView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func exportData(sender: AnyObject) {
        var csvString = NSMutableString()
        csvString.appendString("Time,ax,ay,az,gx,gy,gz,mx,my,mz,Touch,Touch Force")
        
        let dataCache = WaxProcessor.getProcessor().dataCache
        
        for i in 0..<dataCache.count() {
            let data = dataCache[i]
            csvString.appendString("\n\(data.time),\(data.acc.x),\(data.acc.y),\(data.acc.z),\(data.gyro.x),\(data.gyro.y),\(data.gyro.z),\(data.mag.x),\(data.mag.y),\(data.mag.z),\(data.touch),\(data.touchForce)")
        }
        
        let fileManager = (NSFileManager.defaultManager())
        let directorys : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        
        if ((directorys) != nil) {
            
            let directories:[String] = directorys!;
            let dictionary = directories[0];
            let datafile = "data.csv"
            let datapath = dictionary.stringByAppendingPathComponent(datafile);
            
            println("\(datapath)")
            
            csvString.writeToFile(datapath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
            
            var myMail:MFMailComposeViewController!
            
            if(MFMailComposeViewController.canSendMail()){
                
                myMail = MFMailComposeViewController()
                
                // set the subject
                myMail.setSubject("Expressive Touch export")
                
                //Add some text to the message body
                var sentfrom = "Expressive Touch"
                myMail.setMessageBody(sentfrom, isHTML: true)
                
                var testData: NSData = NSData(contentsOfFile: datapath)!
                
                myMail.addAttachmentData(testData, mimeType: "text/csv", fileName: "data.csv")
                
                //Display the view controller
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
    
    override func viewDidDisappear(animated: Bool) {
        interactionView.detector.stopDetection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}