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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        do {
            audioPlayers = [
                "bassDrum": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: "kick-acoustic01")),
                "rideCymbal": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: "ride-acoustic02")),
                "crashCymbal": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: "crash-acoustic")),
                "hiHat": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: "hihat-acoustic01")),
                "highTom": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: "tom-acoustic01")),
                "lowTom": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: "tom-acoustic02")),
                "snare": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: "snare")),
                "floorTom": try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: "openhat-acoustic01"))
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
    
    @IBAction func bassDrum(sender: AnyObject) {
        audioPlayers["bassDrum"]?.play()
    }
    
    @IBAction func rideCymbal(sender: AnyObject) {
        audioPlayers["rideCymbal"]?.play()
    }
    
    @IBAction func crashCymbal(sender: AnyObject) {
        audioPlayers["crashCymbal"]?.play()
    }
    
    @IBAction func hiHat(sender: AnyObject) {
        audioPlayers["hiHat"]?.play()
    }
    
    @IBAction func highTom(sender: AnyObject) {
        audioPlayers["highTom"]?.play()
    }
    
    @IBAction func lowTom(sender: AnyObject) {
        audioPlayers["lowTom"]?.play()
    }
    
    @IBAction func snare(sender: AnyObject) {
        audioPlayers["snare"]?.play()
    }
    
    @IBAction func floorTom(sender: AnyObject) {
        audioPlayers["floorTom"]?.play()
    }
}