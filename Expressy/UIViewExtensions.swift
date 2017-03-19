//
//  UIViewExtensions.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 01/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var circleMask: Bool {
        get {
            return layer.cornerRadius == frame.height / 2
        }
        set {
            layer.cornerRadius = frame.height / 2
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
}

extension UIButton {
    @IBInspectable var aspectFit: Bool {
        get {
            return imageView?.contentMode == UIViewContentMode.scaleAspectFit
        }
        set {
            imageView?.contentMode = UIViewContentMode.scaleAspectFit
        }
    }
}
