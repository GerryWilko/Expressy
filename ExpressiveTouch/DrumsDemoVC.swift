//
//  DrumsDemoVC.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 01/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import AVFoundation

class DrumsDemoVC : UIViewController {
    private var audioPlayers: [String:AVAudioPlayer]!
    
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
        do {
            audioPlayers = [
                "bassDrum": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("kick-acoustic01", ofType: "wav")!)),
                "rideCymbal": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("ride-acoustic02", ofType: "wav")!)),
                "crashCymbal": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("crash-acoustic", ofType: "wav")!)),
                "hiHat": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("hihat-acoustic01", ofType: "wav")!)),
                "highTom": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("tom-acoustic01", ofType: "wav")!)),
                "lowTom": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("tom-acoustic02", ofType: "wav")!)),
                "snare": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("snare", ofType: "mp3")!)),
                "floorTom": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("kick-acoustic01", ofType: "wav")!))
            ]
            audioPlayers.forEach({ (key, ap) -> () in
                ap.prepareToPlay()
            })
        }
        catch {
            let alert = UIAlertController(title: "Error", message: "Unable to load audio files. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (sender) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
    
    func bassDrum(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            if let player = audioPlayers["bassDrum"] {
                if player.playing {
                    player.pause()
                    player.currentTime = 0
                }
                player.volume = recognizer.tapForce
                player.play()
            }
        }
    }
    
    func rideCymbal(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            if let player = audioPlayers["rideCymbal"] {
                if player.playing {
                    player.pause()
                    player.currentTime = 0
                }
                player.volume = recognizer.tapForce
                player.play()
            }
        }
    }
    
    func crashCymbal(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            if let player = audioPlayers["crashCymbal"] {
                if player.playing {
                    player.pause()
                    player.currentTime = 0
                }
                player.volume = recognizer.tapForce
                player.play()
            }
        }
    }
    
    func hiHat(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            if let player = audioPlayers["hiHat"] {
                if player.playing {
                    player.pause()
                    player.currentTime = 0
                }
                player.volume = recognizer.tapForce
                player.play()
            }
        }
    }
    
    func highTom(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            if let player = audioPlayers["highTom"] {
                if player.playing {
                    player.pause()
                    player.currentTime = 0
                }
                player.volume = recognizer.tapForce
                player.play()
            }
        }
    }
    
    func lowTom(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            if let player = audioPlayers["lowTom"] {
                if player.playing {
                    player.pause()
                    player.currentTime = 0
                }
                player.volume = recognizer.tapForce
                player.play()
            }
        }
    }
    
    func snare(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            if let player = audioPlayers["snare"] {
                if player.playing {
                    player.pause()
                    player.currentTime = 0
                }
                player.volume = recognizer.tapForce
                player.play()
            }
        }
    }
    
    func floorTom(recognizer:EXTForceGestureRecognizer) {
        if recognizer.state == .Began {
            if let player = audioPlayers["floorTom"] {
                if player.playing {
                    player.pause()
                    player.currentTime = 0
                }
                player.volume = recognizer.tapForce
                player.play()
            }
        }
    }
}