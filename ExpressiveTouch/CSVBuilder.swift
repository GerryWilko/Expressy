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
    
    /// Initialises a CSV builder for logging of data and exporting via email.
    /// - parameter fileNames: Array of file names for CSV files.
    /// - parameter headerLines: Array of headerLines for CSV files.
    init(fileNames:[String], headerLines:[String]) {
        assert(fileNames.count == headerLines.count)
        
        self.fileNames = fileNames
        csvStrings = headerLines
    }
    
    /// Function to append new row of data.
    /// - parameter data: CSV formatted data string to append.
    /// - parameter index: Index of CSV file to append data to.
    func appendRow(data:String, index:Int) {
        csvStrings[index] += "\n" + data
    }
    
    /// Function to setup email and present to passed view controller.
    /// - parameter viewController: View controller to present email view to.
    /// - parameter subject: Subject of email.
    func emailCSV(viewController:UIViewController, subject:String) {
        let fileManager = (NSFileManager.defaultManager())
        let directorys : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        
        if ((directorys) != nil) {
            
            let directories:[String] = directorys!
            let dictionary = directories[0]
            var dataPaths = [String]()
            
            for index in 0..<fileNames.count {
                let datapath = dictionary.stringByAppendingPathComponent(fileNames[index])
            
                do {
                    try csvStrings[index].writeToFile(datapath, atomically: true, encoding: NSUTF8StringEncoding)
                } catch _ {
                }
                dataPaths.append(datapath)
            }
            
            if(MFMailComposeViewController.canSendMail()){
                
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                
                mail.setSubject(subject)
                
                for index in 0..<dataPaths.count {
                    let data: NSData = NSData(contentsOfFile: dataPaths[index])!
                    
                    mail.addAttachmentData(data, mimeType: "text/csv", fileName: fileNames[index])
                }
                mail.setToRecipients(["gerrywilko@googlemail.com"])
                viewController.presentViewController(mail, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Error exporting CSV", message: "Your device cannot send emails.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                viewController.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else {
            let alert = UIAlertController(title: "Error exporting CSV", message: "There was an error storing the CSV.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            viewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}