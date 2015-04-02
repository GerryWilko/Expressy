//
//  CSVBuilder.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 27/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import MessageUI

class CSVBuilder: NSObject, MFMailComposeViewControllerDelegate {
    private let fileNames:[String]
    private var csvStrings:[String]
    
    init(fileNames:[String], headerLines:[String]) {
        assert(fileNames.count == headerLines.count)
        
        self.fileNames = fileNames
        csvStrings = headerLines
    }
    
    func appendRow(data:String, index:Int) {
        csvStrings[index] += "\n" + data
    }
    
    func emailCSV(viewController:UIViewController, subject:String) {
        let fileManager = (NSFileManager.defaultManager())
        let directorys : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        
        if ((directorys) != nil) {
            
            let directories:[String] = directorys!
            let dictionary = directories[0]
            var dataPaths = [String]()
            
            for index in 0..<fileNames.count {
                let datapath = dictionary.stringByAppendingPathComponent(fileNames[index])
            
                csvStrings[index].writeToFile(datapath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
                dataPaths.append(datapath)
            }
            
            if(MFMailComposeViewController.canSendMail()){
                
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                
                mail.setSubject(subject)
                
                for index in 0..<dataPaths.count {
                    var data: NSData = NSData(contentsOfFile: dataPaths[index])!
                    
                    mail.addAttachmentData(data, mimeType: "text/csv", fileName: fileNames[index])
                }
                
                viewController.presentViewController(mail, animated: true, completion: nil)
            }
            else {
                var alert = UIAlertController(title: "Error exporting CSV", message: "Your device cannot send emails.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                viewController.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else {
            var alert = UIAlertController(title: "Error exporting CSV", message: "There was an error storing the CSV.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            viewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}