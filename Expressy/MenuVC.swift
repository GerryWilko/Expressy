//
//  MenuVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 01/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation

class MenuVC : UITableViewController {
    @IBOutlet weak var connectDeviceBtn: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        performSegueWithIdentifier("connectDeviceSegue", sender: self)
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
}