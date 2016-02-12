//
//  PaintingDemoColorPickerVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 04/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import DAScratchPad

class PaintingDemoColorPickerVC: UIViewController {
    var paintView:DAScratchPadView!
    
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
        
        colorPreview.backgroundColor = paintView.drawColor
        
        var red:CGFloat = 0, green:CGFloat = 0, blue:CGFloat = 0, alpha:CGFloat = 0
        paintView.drawColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        redSlider.value = Float(red)
        greenSlider.value = Float(green)
        blueSlider.value = Float(blue)
        opacitySlider.value = Float(alpha)
    }
    
    @IBAction func redChanged(sender: AnyObject) {
        let newColor = UIColor(red: CGFloat(redSlider.value), green: CGFloat(greenSlider.value), blue: CGFloat(blueSlider.value), alpha: CGFloat(opacitySlider.value))
        paintView.drawColor = newColor
        colorPreview.backgroundColor = newColor
    }
    
    @IBAction func greenChanged(sender: AnyObject) {
        let newColor = UIColor(red: CGFloat(redSlider.value), green: CGFloat(greenSlider.value), blue: CGFloat(blueSlider.value), alpha: CGFloat(opacitySlider.value))
        paintView.drawColor = newColor
        colorPreview.backgroundColor = newColor
    }
    
    @IBAction func blueChanged(sender: AnyObject) {
        let newColor = UIColor(red: CGFloat(redSlider.value), green: CGFloat(greenSlider.value), blue: CGFloat(blueSlider.value), alpha: CGFloat(opacitySlider.value))
        paintView.drawColor = newColor
        colorPreview.backgroundColor = newColor
    }
    
    @IBAction func opacityChanged(sender: AnyObject) {
        let newColor = UIColor(red: CGFloat(redSlider.value), green: CGFloat(greenSlider.value), blue: CGFloat(blueSlider.value), alpha: CGFloat(opacitySlider.value))
        paintView.drawColor = newColor
        colorPreview.backgroundColor = newColor
    }
}