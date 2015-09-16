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
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func playVideo() {
        let path = NSBundle.mainBundle().pathForResource("bbb_sunflower", ofType:"mp4")
        let url = NSURL.fileURLWithPath(path!)
        player = AVPlayer(URL: url)
        player?.play()
        
        let rollRecognizer = EXTRollGestureRecognizer(target: self, action: Selector("rollVideo:"))
        
        rollRecognizer.cancelsTouchesInView = false
        rollRecognizer.rollThreshold = 10.0
        
        view.addGestureRecognizer(rollRecognizer)
    }
    
    func rollVideo(recognizer:EXTRollGestureRecognizer) {
        switch recognizer.state {
        case .Changed:
            player?.currentItem?.stepByCount(Int(recognizer.currentRoll / 10.0))
        case .Ended:
            player?.play()
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.translucent = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        playVideo()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.translucent = true
    }
}