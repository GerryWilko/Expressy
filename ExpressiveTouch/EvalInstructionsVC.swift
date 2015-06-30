//
//  EvalInstructionsVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 26/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation

class EvalInstructionsVC: UIViewController {
    private var moviePlayer: AVPlayer?
    var videoPath:String!
    
    @IBOutlet weak var video: AVPlayerViewController!
    
    private func playVideo() {
        if let videoPath = self.videoPath {
            let path = NSBundle.mainBundle().pathForResource(videoPath, ofType:"mp4")
            let url = NSURL.fileURLWithPath(path!)
            video.player = AVPlayer(URL: url)
            video.player?.play()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        playVideo()
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}