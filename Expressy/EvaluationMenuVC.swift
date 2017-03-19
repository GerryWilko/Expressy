//
//  EvaluationMenuVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 01/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import MessageUI

class EvaluationMenuVC: UITableViewController, MFMailComposeViewControllerDelegate {
    fileprivate var currentParticipant:Participant?
    
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
        let alert = UIAlertController(title: "Participant Details", message: "Please enter your details below:", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField) -> Void in
            textField.placeholder = "Age"
            textField.keyboardType = UIKeyboardType.numbersAndPunctuation
        }
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.currentParticipant = Participant(id: EvalUtils.generateParticipantID(), age: Int(alert.textFields![0].text!)!, csvFiles:[CSVBuilder]())
            
            self.navigationItem.title = self.navigationItem.title! + " \(self.currentParticipant!.id)"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
        SensorCache.setRecordLimit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        finishBtn.isEnabled = catForceCell.accessoryType == .checkmark &&
            freeForceCell.accessoryType == .checkmark &&
            rollRangeCell.accessoryType == .checkmark &&
            pitchRangeCell.accessoryType == .checkmark &&
            catFlickCell.accessoryType == .checkmark
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            SensorCache.resetLimit()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch (id){
            case "catForceSegue":
                let catForceVC = segue.destination as! CatForceEvalVC
                catForceVC.participant = currentParticipant?.id
                catForceVC.evalVC = self
                break
            case "freeForceSegue":
                let freeForceVC = segue.destination as! FreeForceEvalVC
                freeForceVC.participant = currentParticipant?.id
                freeForceVC.evalVC = self
                break
            case "rollRangeSegue":
                let rollEvalVC = segue.destination as! RollEvalVC
                rollEvalVC.participant = currentParticipant?.id
                rollEvalVC.evalVC = self
                break
            case "pitchRangeSegue":
                let pitchEvalVC = segue.destination as! PitchEvalVC
                pitchEvalVC.participant = currentParticipant?.id
                pitchEvalVC.evalVC = self
                break
            case "catFlickSegue":
                let catFlickVC = segue.destination as! FlickEvalVC
                catFlickVC.participant = currentParticipant?.id
                catFlickVC.evalVC = self
                break
            default:
                break
            }
        }
    }
    
    func back(_ sender:NSObject) {
        let alert = UIAlertController(title: "Are you sure?", message: "Leaving now will discard current evalauation data.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func finish(_ sender: AnyObject) {
        emailCSV()
    }
    
    func completeFreeForce(_ csv:CSVBuilder) {
        freeForceCell.accessoryType = .checkmark
        freeForceCell.isUserInteractionEnabled = false
        currentParticipant?.csvFiles.append(csv)
        catForceCell.accessoryType = .disclosureIndicator
        catForceCell.isUserInteractionEnabled = true
    }
    
    func completeCatForce(_ csv:CSVBuilder) {
        catForceCell.accessoryType = .checkmark
        catForceCell.isUserInteractionEnabled = false
        currentParticipant?.csvFiles.append(csv)
        rollRangeCell.accessoryType = .disclosureIndicator
        rollRangeCell.isUserInteractionEnabled = true
    }
    
    func completeRoll(_ csv:CSVBuilder) {
        rollRangeCell.accessoryType = .checkmark
        rollRangeCell.isUserInteractionEnabled = false
        currentParticipant?.csvFiles.append(csv)
        pitchRangeCell.accessoryType = .disclosureIndicator
        pitchRangeCell.isUserInteractionEnabled = true
    }
    
    func completePitch(_ csv:CSVBuilder) {
        pitchRangeCell.accessoryType = .checkmark
        pitchRangeCell.isUserInteractionEnabled = false
        currentParticipant?.csvFiles.append(csv)
        catFlickCell.accessoryType = .disclosureIndicator
        catFlickCell.isUserInteractionEnabled = true
    }
    
    func completeFlick(_ csv:CSVBuilder) {
        catFlickCell.accessoryType = .checkmark
        catFlickCell.isUserInteractionEnabled = false
        currentParticipant?.csvFiles.append(csv)
    }
    
    func emailCSV() {
        if(MFMailComposeViewController.canSendMail()){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            mail.setSubject("Participant: \(currentParticipant!.id), Age: \(currentParticipant!.age)")
            
            for csv in currentParticipant!.csvFiles {
                for file in csv.files {
                    if let data = file.1.data(using: String.Encoding.utf8) {
                        mail.addAttachmentData(data, mimeType: "text/csv", fileName: file.0)
                    } else {
                        let alert = UIAlertController(title: "Error exporting CSV", message: "Unable to read CSV file.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        present(alert, animated: true, completion: nil)
                    }
                }
            }
            mail.setToRecipients(["gerrywilko@googlemail.com"])
            present(mail, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error exporting CSV", message: "Your device cannot send emails.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }
}

struct Participant {
    let id:UInt32
    let age:Int
    var csvFiles:[CSVBuilder]
}
