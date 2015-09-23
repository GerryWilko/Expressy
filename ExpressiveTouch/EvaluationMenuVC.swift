//
//  EvaluationMenuVC.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 01/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import MessageUI

class EvaluationMenuVC: UITableViewController, MFMailComposeViewControllerDelegate {
    private var currentParticipant:Participant?
    
    @IBOutlet weak var finishBtn: UIBarButtonItem!
    @IBOutlet weak var catForceCell: UITableViewCell!
    @IBOutlet weak var freeForceCell: UITableViewCell!
    @IBOutlet weak var rollRangeCell: UITableViewCell!
    @IBOutlet weak var pitchRangeCell: UITableViewCell!
    @IBOutlet weak var catFlickCell: UITableViewCell!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        let alert = UIAlertController(title: "Participant Details", message: "Please enter your details below:", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Age"
            textField.keyboardType = UIKeyboardType.NumbersAndPunctuation
        }
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.currentParticipant = Participant(id: EvalUtils.generateParticipantID(), age: Int(alert.textFields![0].text!)!, csvFiles:[CSVBuilder]())
            
            self.navigationItem.title = self.navigationItem.title! + " \(self.currentParticipant!.id)"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        presentViewController(alert, animated: true, completion: nil)
        SensorCache.setRecordLimit()
    }
    
    override func viewDidAppear(animated: Bool) {
        finishBtn.enabled = catForceCell.accessoryType == .Checkmark &&
            freeForceCell.accessoryType == .Checkmark &&
            rollRangeCell.accessoryType == .Checkmark &&
            pitchRangeCell.accessoryType == .Checkmark &&
            catFlickCell.accessoryType == .Checkmark
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed() {
            SensorCache.resetLimit()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier {
            switch (id){
            case "catForceSegue":
                let catForceVC = segue.destinationViewController as! CatForceEvalVC
                catForceVC.participant = currentParticipant?.id
                catForceVC.evalVC = self
                break
            case "freeForceSegue":
                let freeForceVC = segue.destinationViewController as! FreeForceEvalVC
                freeForceVC.participant = currentParticipant?.id
                freeForceVC.evalVC = self
                break
            case "rollRangeSegue":
                let rollEvalVC = segue.destinationViewController as! RollEvalVC
                rollEvalVC.participant = currentParticipant?.id
                rollEvalVC.evalVC = self
                break
            case "pitchRangeSegue":
                let pitchEvalVC = segue.destinationViewController as! PitchEvalVC
                pitchEvalVC.participant = currentParticipant?.id
                pitchEvalVC.evalVC = self
                break
            case "catFlickSegue":
                let catFlickVC = segue.destinationViewController as! FlickEvalVC
                catFlickVC.participant = currentParticipant?.id
                catFlickVC.evalVC = self
                break
            default:
                break
            }
        }
    }
    
    func back(sender:NSObject) {
        let alert = UIAlertController(title: "Are you sure?", message: "Leaving now will discard current evalauation data.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func finish(sender: AnyObject) {
        emailCSV()
    }
    
    func completeFreeForce(csv:CSVBuilder) {
        freeForceCell.accessoryType = .Checkmark
        freeForceCell.userInteractionEnabled = false
        currentParticipant?.csvFiles.append(csv)
        catForceCell.accessoryType = .DisclosureIndicator
        catForceCell.userInteractionEnabled = true
    }
    
    func completeCatForce(csv:CSVBuilder) {
        catForceCell.accessoryType = .Checkmark
        catForceCell.userInteractionEnabled = false
        currentParticipant?.csvFiles.append(csv)
        rollRangeCell.accessoryType = .DisclosureIndicator
        rollRangeCell.userInteractionEnabled = true
    }
    
    func completeRoll(csv:CSVBuilder) {
        rollRangeCell.accessoryType = .Checkmark
        rollRangeCell.userInteractionEnabled = false
        currentParticipant?.csvFiles.append(csv)
        pitchRangeCell.accessoryType = .DisclosureIndicator
        pitchRangeCell.userInteractionEnabled = true
    }
    
    func completePitch(csv:CSVBuilder) {
        pitchRangeCell.accessoryType = .Checkmark
        pitchRangeCell.userInteractionEnabled = false
        currentParticipant?.csvFiles.append(csv)
        catFlickCell.accessoryType = .DisclosureIndicator
        catFlickCell.userInteractionEnabled = true
    }
    
    func completeFlick(csv:CSVBuilder) {
        catFlickCell.accessoryType = .Checkmark
        catFlickCell.userInteractionEnabled = false
        currentParticipant?.csvFiles.append(csv)
    }
    
    func emailCSV() {
        if(MFMailComposeViewController.canSendMail()){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            mail.setSubject("Participant: \(currentParticipant!.id), Age: \(currentParticipant!.age)")
            
            for csv in currentParticipant!.csvFiles {
                for file in csv.files {
                    if let data = file.1.dataUsingEncoding(NSUTF8StringEncoding) {
                        mail.addAttachmentData(data, mimeType: "text/csv", fileName: file.0)
                    } else {
                        let alert = UIAlertController(title: "Error exporting CSV", message: "Unable to read CSV file.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
            mail.setToRecipients(["gerrywilko@googlemail.com"])
            presentViewController(mail, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error exporting CSV", message: "Your device cannot send emails.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        dismissViewControllerAnimated(true, completion: nil)
    }
}

struct Participant {
    let id:UInt32
    let age:Int
    var csvFiles:[CSVBuilder]
}