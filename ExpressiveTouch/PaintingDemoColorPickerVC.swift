//
//  PaintingDemoColorPickerVC.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 04/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation

class PaintingDemoColorPickerVC: UIViewController {
    var color = UIColor.blackColor()
    
    @IBOutlet weak var colorPreview: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var opacitySlider: UISlider!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorPreview.backgroundColor = color
    }
    
    @IBAction func redChanged(sender: AnyObject) {
        color = UIColor(red: CGFloat(redSlider.value), green: CGFloat(greenSlider.value), blue: CGFloat(blueSlider.value), alpha: CGFloat(opacitySlider.value))
    }
    
    @IBAction func greenChanged(sender: AnyObject) {
    }
    
    @IBAction func blueChanged(sender: AnyObject) {
    }
    
    @IBAction func opacityChanged(sender: AnyObject) {
    }
}