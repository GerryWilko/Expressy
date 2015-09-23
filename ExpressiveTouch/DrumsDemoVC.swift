//
//  DrumsDemoVC.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 01/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import AVFoundation
import SVProgressHUD
import MessageUI

class DrumsDemoVC : UIViewController, MFMailComposeViewControllerDelegate {
    private let numPlayers = 10
    
    private var audioPlayers: [String:[AVAudioPlayer]]!
    private var startRecordTime:NSTimeInterval?
    
    @IBOutlet weak var bassDrumBtn: UIButton!
    @IBOutlet weak var rideCymbalBtn: UIButton!
    @IBOutlet weak var crashCymbalBtn: UIButton!
    @IBOutlet weak var hihatBtn: UIButton!
    @IBOutlet weak var highTomBtn: UIButton!
    @IBOutlet weak var lowTomBtn: UIButton!
    @IBOutlet weak var snareBtn: UIButton!
    @IBOutlet weak var floorTomBtn: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        audioPlayers = [
            "bassDrum": createPlayers(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("kick-acoustic01", ofType: "wav")!)),
            "rideCymbal": createPlayers(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("ride-acoustic02", ofType: "wav")!)),
            "crashCymbal": createPlayers(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("crash-acoustic", ofType: "wav")!)),
            "hiHat": createPlayers(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("hihat-acoustic01", ofType: "wav")!)),
            "highTom": createPlayers(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("tom-acoustic01", ofType: "wav")!)),
            "lowTom": createPlayers(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("tom-acoustic02", ofType: "wav")!)),
            "snare": createPlayers(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("snare", ofType: "mp3")!)),
            "floorTom": createPlayers(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("kick-acoustic01", ofType: "wav")!))
        ]
        audioPlayers.forEach({ (key, aps) -> () in
            aps.forEach({ (p) -> () in
                p.prepareToPlay()
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bassDrumBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: Selector("bassDrum:"), event: EXTForceEvent.AllPress))
        rideCymbalBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: Selector("rideCymbal:"), event: EXTForceEvent.AllPress))
        crashCymbalBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: Selector("crashCymbal:"), event: EXTForceEvent.AllPress))
        hihatBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: Selector("hiHat:"), event: EXTForceEvent.AllPress))
        highTomBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: Selector("highTom:"), event: EXTForceEvent.AllPress))
        lowTomBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: Selector("lowTom:"), event: EXTForceEvent.AllPress))
        snareBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: Selector("snare:"), event: EXTForceEvent.AllPress))
        floorTomBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: Selector("floorTom:"), event: EXTForceEvent.AllPress))
    }
    
    @IBAction func etToggle(sender: AnyObject) {
        bassDrumBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.enabled = !recognizer.enabled
        })
        rideCymbalBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.enabled = !recognizer.enabled
        })
        crashCymbalBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.enabled = !recognizer.enabled
        })
        hihatBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.enabled = !recognizer.enabled
        })
        highTomBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.enabled = !recognizer.enabled
        })
        lowTomBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.enabled = !recognizer.enabled
        })
        snareBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.enabled = !recognizer.enabled
        })
        floorTomBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.enabled = !recognizer.enabled
        })
        SVProgressHUD.showImage(UIImage(named: "ExpressiveTouchIcon"), status: self.bassDrumBtn.gestureRecognizers!.first!.enabled ? "Expressive Touch Enabled" : "Expressive Touch Disabled")
    }
    
    func createPlayers(url:NSURL) -> [AVAudioPlayer] {
        var players = [AVAudioPlayer]()
        do {
            for _ in 0..<numPlayers {
                players.append(try AVAudioPlayer(contentsOfURL: url))
            }
        }
        catch {
            let alert = UIAlertController(title: "Error", message: "Unable to load audio files. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (sender) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
        return players
    }
    
    func getPlayer(player:[AVAudioPlayer]) -> AVAudioPlayer {
        return player.filter({ (p) -> Bool in
            !p.playing
        }).first ?? player.first!
    }
    
    func bassDrum(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            let player = getPlayer(audioPlayers["bassDrum"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func bassDrumStd(sender: AnyObject) {
        let player = getPlayer(audioPlayers["bassDrum"]!)
        player.volume = 1.0
        player.play()
    }
    
    func rideCymbal(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            let player = getPlayer(audioPlayers["rideCymbal"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func rideCymbalStd(sender: AnyObject) {
        let player = getPlayer(audioPlayers["rideCymbal"]!)
        player.volume = 1.0
        player.play()
    }
    
    func crashCymbal(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            let player = getPlayer(audioPlayers["crashCymbal"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func crashCymbalStd(sender: AnyObject) {
        let player = getPlayer(audioPlayers["crashCymbal"]!)
        player.volume = 1.0
        player.play()
    }
    
    func hiHat(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            let player = getPlayer(audioPlayers["hiHat"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func hiHatStd(sender: AnyObject) {
        let player = getPlayer(audioPlayers["hiHat"]!)
        player.volume = 1.0
        player.play()
    }
    
    func highTom(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            let player = getPlayer(audioPlayers["highTom"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func highTomStd(sender: AnyObject) {
        let player = getPlayer(audioPlayers["highTom"]!)
        player.volume = 1.0
        player.play()
    }
    
    func lowTom(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            let player = getPlayer(audioPlayers["lowTom"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func lowTomStd(sender: AnyObject) {
        let player = getPlayer(audioPlayers["lowTom"]!)
        player.volume = 1.0
        player.play()
    }
    
    func snare(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            let player = getPlayer(audioPlayers["snare"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func snareStd(sender: AnyObject) {
        let player = getPlayer(audioPlayers["snare"]!)
        player.volume = 1.0
        player.play()
    }
    
    func floorTom(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            let player = getPlayer(audioPlayers["floorTom"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func floorTomStd(sender: AnyObject) {
        let player = getPlayer(audioPlayers["floorTom"]!)
        player.volume = 1.0
        player.play()
    }
    
    @IBAction func RecordBtn(sender: UIBarButtonItem) {
        if let startTime = startRecordTime {
            sender.image = UIImage(named: "RecordIcon")
            startRecordTime = nil
            
            let csv = CSVBuilder(files: ["drumsDemo-sensordata.csv" : SensorData.headerLine()])
            
            EvalUtils.logDataBetweenTimes(startTime, endTime: NSDate.timeIntervalSinceReferenceDate(), csv: csv, file: "drumsDemo-sensordata.csv")
            
            emailCSV(csv)
            SensorCache.resetLimit()
        } else {
            sender.image = UIImage(named: "PauseIcon")
            startRecordTime = NSDate.timeIntervalSinceReferenceDate()
            SensorCache.setRecordLimit()
        }
    }
    
    func emailCSV(csv:CSVBuilder) {
        if(MFMailComposeViewController.canSendMail()){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            mail.setSubject("Drums Demo sensor data")
            
            for file in csv.files {
                if let data = file.1.dataUsingEncoding(NSUTF8StringEncoding) {
                    mail.addAttachmentData(data, mimeType: "text/csv", fileName: file.0)
                } else {
                    let alert = UIAlertController(title: "Error exporting CSV", message: "Unable to read CSV file.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    presentViewController(alert, animated: true, completion: nil)
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
    }
}