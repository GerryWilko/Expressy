//
//  PaintingDemoVC.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 03/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation

class PaintingDemoVC: UIViewController {
    private var initialWidth:CGFloat!
    
    @IBOutlet weak var strokeWidthHUD: UIView!
    @IBOutlet weak var strokeWidthBtn: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let paintView = self.view as! DAScratchPadView
        initialWidth = paintView.drawWidth
        
        let paintRoll = EXTRollGestureRecognizer(target: self, action: Selector("paintRoll:"))
        let paintFlick = EXTFlickGestureRecognizer(target: self, action: Selector("paintFlick:"))
        
        paintRoll.cancelsTouchesInView = false
        paintFlick.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(paintRoll)
        self.view.addGestureRecognizer(paintFlick)
        strokeWidthBtn.addGestureRecognizer(EXTRollGestureRecognizer(target: self, action: Selector("strokeRoll:")))
    }
    
    func strokeRoll(recognizer:EXTRollGestureRecognizer) {
        let strokeIndi = strokeWidthHUD.viewWithTag(100)!
        let paintView = self.view as! DAScratchPadView
        switch recognizer.state {
        case .Began:
            initialWidth = paintView.drawWidth
            strokeWidthHUD.hidden = false
            strokeIndi.frame = CGRect(origin: strokeIndi.frame.origin, size: CGSize(width: paintView.drawWidth, height: paintView.drawWidth))
            strokeIndi.cornerRadius = paintView.drawWidth / 2.0
        case .Changed:
            paintView.drawWidth = initialWidth + CGFloat(recognizer.currentRoll / 2.00)
            strokeIndi.frame = CGRect(origin: strokeIndi.frame.origin, size: CGSize(width: paintView.drawWidth, height: paintView.drawWidth))
            strokeIndi.cornerRadius = paintView.drawWidth / 2.0
        case .Ended:
            strokeWidthHUD.hidden = true
        default:
            break
        }
    }
    
    func paintRoll(recognizer:EXTRollGestureRecognizer) {
        let paintView = self.view as! DAScratchPadView
        switch recognizer.state {
        case .Began:
            initialWidth = paintView.drawWidth
        case .Changed:
            paintView.drawWidth = initialWidth + CGFloat(recognizer.currentRoll / 2.00)
        default:
            break
        }
    }
    
    func paintFlick(recognizer:EXTFlickGestureRecognizer) {
        let paintView = self.view as! DAScratchPadView
        switch recognizer.state {
        case .Ended:
            break
        default:
            break
        }
    }
    
    @IBAction func clear(sender: AnyObject) {
        let paintView = self.view as! DAScratchPadView
        paintView.clearToColor(UIColor.whiteColor())
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "colorPickerSegue" {
            let destinationVC = segue.destinationViewController as! PaintingDemoColorPickerVC
            destinationVC.paintView = self.view as! DAScratchPadView
        }
    }
}