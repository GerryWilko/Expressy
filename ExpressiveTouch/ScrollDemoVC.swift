//
//  ScrollDemoVC.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 04/09/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class ScrollDemoVC: UICollectionViewController {
    let detector:InteractionDetector
    
    private var scrollPace:CGFloat!
    
    required init?(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: SensorProcessor.dataCache)
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        detector.startDetection()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        detector.stopDetection()
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1000
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) 
        let image = cell.viewWithTag(100) as! UIImageView
        
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: "http://lorempixel.com/600/400")!), queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if error == nil {
                image.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        detector.clearSubscriptions()
        detector.touchDown()
    }
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        detector.touchUp()
        scrollPace = velocity.y
        detector.subscribe(EventType.Metrics) { (data) -> Void in
            self.scrollPace! += CGFloat(self.detector.currentRotation)
            if (velocity.y > 0.0)
            {
                self.scrollPace = self.scrollPace < 0.0 ? 0.0 : self.scrollPace
            } else {
                self.scrollPace = self.scrollPace > 0.0 ? 0.0 : self.scrollPace
            }
            self.collectionView?.setContentOffset(CGPoint(x: self.collectionView!.contentOffset.x, y: self.collectionView!.contentOffset.y + self.scrollPace), animated: true)
        }
    }
}