//
//  VideoDemoVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 07/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit
import MessageUI

class VideoDemoVC: AVPlayerViewController, MFMailComposeViewControllerDelegate {
    fileprivate var startRecordTime:TimeInterval?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func playVideo() {
        let path = Bundle.main.path(forResource: "bbb_sunflower", ofType:"mp4")
        let url = URL(fileURLWithPath: path!)
        player = AVPlayer(url: url)
        player?.play()
        
        let rollRecognizer = EXTRollGestureRecognizer(target: self, action: #selector(VideoDemoVC.rollVideo(_:)))
        
        rollRecognizer.cancelsTouchesInView = false
        rollRecognizer.rollThreshold = 10.0
        
        view.addGestureRecognizer(rollRecognizer)
    }
    
    func rollVideo(_ recognizer:EXTRollGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            player?.currentItem?.step(byCount: Int(recognizer.currentRoll / 10.0))
        case .ended:
            player?.play()
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.isTranslucent = true
    }
    
    @IBAction func RecordBtn(_ sender: UIBarButtonItem) {
        if let startTime = startRecordTime {
            sender.image = UIImage(named: "RecordIcon")
            startRecordTime = nil
            
            let csv = CSVBuilder(files: ["videoDemo-sensordata.csv" : SensorData.headerLine()])
            
            EvalUtils.logDataBetweenTimes(startTime, endTime: Date.timeIntervalSinceReferenceDate, csv: csv, file: "videoDemo-sensordata.csv")
            
            emailCSV(csv)
            SensorCache.resetLimit()
        } else {
            sender.image = UIImage(named: "PauseIcon")
            startRecordTime = Date.timeIntervalSinceReferenceDate
            SensorCache.setRecordLimit()
        }
    }
    
    func emailCSV(_ csv:CSVBuilder) {
        if(MFMailComposeViewController.canSendMail()){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            mail.setSubject("Video Demo sensor data")
            
            for file in csv.files {
                if let data = file.1.data(using: String.Encoding.utf8) {
                    mail.addAttachmentData(data, mimeType: "text/csv", fileName: file.0)
                } else {
                    let alert = UIAlertController(title: "Error exporting CSV", message: "Unable to read CSV file.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    present(alert, animated: true, completion: nil)
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
    }
}
