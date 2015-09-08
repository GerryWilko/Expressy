//
//  VideoDemoVC.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 07/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

class VideoDemoVC: AVPlayerViewController {
    @IBOutlet weak var currentTimeLbl: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func playVideo() {
        let path = NSBundle.mainBundle().pathForResource("bbb_sunflower", ofType:"mp4")
        let url = NSURL.fileURLWithPath(path!)
        player = AVPlayer(URL: url)
        player?.play()
        showsPlaybackControls = false
        
        player?.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(1, 1), queue: nil, usingBlock: { (time) -> Void in
            let endTime = CMTimeConvertScale (self.player!.currentItem!.duration, self.player!.currentTime().timescale, CMTimeRoundingMethod.RoundHalfAwayFromZero)
            if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
                let normalizedTime = Float(self.player!.currentTime().value) / Float(endTime.value)
                self.timeSlider?.value = normalizedTime;
            }
            let currentSeconds = self.player!.currentTime().seconds
            let mins = currentSeconds / 60.0
            let secs = fmodf(Float(currentSeconds), Float(60.0))
            self.currentTimeLbl?.text = String(format: "%0.2d:%0.2d",mins,secs)
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        playVideo()
    }
    
    @IBAction func timeChanged(sender: UISlider) {
        let newTime = CMTimeMakeWithSeconds(Double(sender.value) * player!.currentItem!.duration.seconds, player!.currentTime().timescale)
        player?.seekToTime(newTime)
    }
}