//
//  EvalInstructionsVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 26/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation
import MediaPlayer

class EvalInstructionsVC: UIViewController {
    private var moviePlayer: MPMoviePlayerController?
    var videoPath:String!
    
    @IBOutlet weak var video: UIView!
    
    func playVideo() {
        if let videoPath = self.videoPath {
            let path = NSBundle.mainBundle().pathForResource(videoPath, ofType:"mp4")
            let url = NSURL.fileURLWithPath(path!)
            moviePlayer = MPMoviePlayerController(contentURL: url)
            if let player = moviePlayer {
                player.view.frame = video.bounds
                player.prepareToPlay()
                player.scalingMode = MPMovieScalingMode.AspectFit
                video.addSubview(player.view)
            }
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