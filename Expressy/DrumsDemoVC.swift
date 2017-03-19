//
//  DrumsDemoVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 01/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import AVFoundation
import SVProgressHUD
import MessageUI

class DrumsDemoVC : UIViewController, MFMailComposeViewControllerDelegate {
    fileprivate let numPlayers = 10
    
    fileprivate var audioPlayers: [String:[AVAudioPlayer]]!
    fileprivate var startRecordTime:TimeInterval?
    
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
            "bassDrum": createPlayers(URL(fileURLWithPath: Bundle.main.path(forResource: "kick-acoustic01", ofType: "wav")!)),
            "rideCymbal": createPlayers(URL(fileURLWithPath: Bundle.main.path(forResource: "ride-acoustic02", ofType: "wav")!)),
            "crashCymbal": createPlayers(URL(fileURLWithPath: Bundle.main.path(forResource: "crash-acoustic", ofType: "wav")!)),
            "hiHat": createPlayers(URL(fileURLWithPath: Bundle.main.path(forResource: "hihat-acoustic01", ofType: "wav")!)),
            "highTom": createPlayers(URL(fileURLWithPath: Bundle.main.path(forResource: "tom-acoustic01", ofType: "wav")!)),
            "lowTom": createPlayers(URL(fileURLWithPath: Bundle.main.path(forResource: "tom-acoustic02", ofType: "wav")!)),
            "snare": createPlayers(URL(fileURLWithPath: Bundle.main.path(forResource: "snare", ofType: "mp3")!)),
            "floorTom": createPlayers(URL(fileURLWithPath: Bundle.main.path(forResource: "kick-acoustic01", ofType: "wav")!))
        ]
        audioPlayers.forEach({ (key, aps) -> () in
            aps.forEach({ (p) -> () in
                p.prepareToPlay()
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bassDrumBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: #selector(DrumsDemoVC.bassDrum(_:)), event: EXTForceEvent.allPress))
        rideCymbalBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: #selector(DrumsDemoVC.rideCymbal(_:)), event: EXTForceEvent.allPress))
        crashCymbalBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: #selector(DrumsDemoVC.crashCymbal(_:)), event: EXTForceEvent.allPress))
        hihatBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: #selector(DrumsDemoVC.hiHat(_:)), event: EXTForceEvent.allPress))
        highTomBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: #selector(DrumsDemoVC.highTom(_:)), event: EXTForceEvent.allPress))
        lowTomBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: #selector(DrumsDemoVC.lowTom(_:)), event: EXTForceEvent.allPress))
        snareBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: #selector(DrumsDemoVC.snare(_:)), event: EXTForceEvent.allPress))
        floorTomBtn.addGestureRecognizer(EXTForceGestureRecognizer(target: self, action: #selector(DrumsDemoVC.floorTom(_:)), event: EXTForceEvent.allPress))
    }
    
    @IBAction func etToggle(_ sender: AnyObject) {
        bassDrumBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.isEnabled = !recognizer.isEnabled
        })
        rideCymbalBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.isEnabled = !recognizer.isEnabled
        })
        crashCymbalBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.isEnabled = !recognizer.isEnabled
        })
        hihatBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.isEnabled = !recognizer.isEnabled
        })
        highTomBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.isEnabled = !recognizer.isEnabled
        })
        lowTomBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.isEnabled = !recognizer.isEnabled
        })
        snareBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.isEnabled = !recognizer.isEnabled
        })
        floorTomBtn.gestureRecognizers?.forEach({ (recognizer) -> () in
            recognizer.isEnabled = !recognizer.isEnabled
        })
        SVProgressHUD.show(UIImage(named: "ExpressyIcon"), status: self.bassDrumBtn.gestureRecognizers!.first!.isEnabled ? "Expressive Touch Enabled" : "Expressive Touch Disabled")
    }
    
    func createPlayers(_ url:URL) -> [AVAudioPlayer] {
        var players = [AVAudioPlayer]()
        do {
            for _ in 0..<numPlayers {
                players.append(try AVAudioPlayer(contentsOf: url))
            }
        }
        catch {
            let alert = UIAlertController(title: "Error", message: "Unable to load audio files. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (sender) -> Void in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }
        return players
    }
    
    func getPlayer(_ player:[AVAudioPlayer]) -> AVAudioPlayer {
        return player.filter({ (p) -> Bool in
            !p.isPlaying
        }).first ?? player.first!
    }
    
    func bassDrum(_ recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .began {
            let player = getPlayer(audioPlayers["bassDrum"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func bassDrumStd(_ sender: AnyObject) {
        let player = getPlayer(audioPlayers["bassDrum"]!)
        player.volume = 1.0
        player.play()
    }
    
    func rideCymbal(_ recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .began {
            let player = getPlayer(audioPlayers["rideCymbal"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func rideCymbalStd(_ sender: AnyObject) {
        let player = getPlayer(audioPlayers["rideCymbal"]!)
        player.volume = 1.0
        player.play()
    }
    
    func crashCymbal(_ recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .began {
            let player = getPlayer(audioPlayers["crashCymbal"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func crashCymbalStd(_ sender: AnyObject) {
        let player = getPlayer(audioPlayers["crashCymbal"]!)
        player.volume = 1.0
        player.play()
    }
    
    func hiHat(_ recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .began {
            let player = getPlayer(audioPlayers["hiHat"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func hiHatStd(_ sender: AnyObject) {
        let player = getPlayer(audioPlayers["hiHat"]!)
        player.volume = 1.0
        player.play()
    }
    
    func highTom(_ recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .began {
            let player = getPlayer(audioPlayers["highTom"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func highTomStd(_ sender: AnyObject) {
        let player = getPlayer(audioPlayers["highTom"]!)
        player.volume = 1.0
        player.play()
    }
    
    func lowTom(_ recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .began {
            let player = getPlayer(audioPlayers["lowTom"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func lowTomStd(_ sender: AnyObject) {
        let player = getPlayer(audioPlayers["lowTom"]!)
        player.volume = 1.0
        player.play()
    }
    
    func snare(_ recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .began {
            let player = getPlayer(audioPlayers["snare"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func snareStd(_ sender: AnyObject) {
        let player = getPlayer(audioPlayers["snare"]!)
        player.volume = 1.0
        player.play()
    }
    
    func floorTom(_ recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .began {
            let player = getPlayer(audioPlayers["floorTom"]!)
            player.volume = recognizer.tapForce
            player.play()
        }
    }
    
    @IBAction func floorTomStd(_ sender: AnyObject) {
        let player = getPlayer(audioPlayers["floorTom"]!)
        player.volume = 1.0
        player.play()
    }
    
    @IBAction func RecordBtn(_ sender: UIBarButtonItem) {
        if let startTime = startRecordTime {
            sender.image = UIImage(named: "RecordIcon")
            startRecordTime = nil
            
            let csv = CSVBuilder(files: ["drumsDemo-sensordata.csv" : SensorData.headerLine()])
            
            EvalUtils.logDataBetweenTimes(startTime, endTime: Date.timeIntervalSinceReferenceDate, csv: csv, file: "drumsDemo-sensordata.csv")
            
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
            
            mail.setSubject("Drums Demo sensor data")
            
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
