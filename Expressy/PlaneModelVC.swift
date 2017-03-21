//
//  PlaneModelVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 18/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class PlaneModelVC: UIViewController {
    @IBOutlet weak var forceLbl: UILabel!
    @IBOutlet weak var rollLbl: UILabel!
    @IBOutlet weak var pitchLbl: UILabel!
    
    fileprivate var detector:EXTInteractionDetector
    fileprivate var timer:Timer!
    fileprivate var scnView:SCNView!
    
    required init?(coder aDecoder: NSCoder) {
        detector = EXTInteractionDetector(dataCache: SensorProcessor.dataCache)
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        detector.startDetection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        detector.stopDetection()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnView = self.view as! SCNView
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.dae")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // set the scene to the view
        scnView.scene = scene 
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PlaneModelVC.handleTap(_:)))
        scnView.gestureRecognizers?.append(tapGesture)
        
        SensorProcessor.dataCache.subscribe(dataCallback)
        detector.subscribe(.metrics, callback: detectorCallback)
    }
    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: nil)
        
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject! = hitResults[0]
            
            // get its material
            let material = result.node!.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    func dataCallback(_ data:SensorData) {
        let ship = scnView.scene!.rootNode.childNode(withName: "ship", recursively: true)!
        
        ship.orientation = SCNQuaternion(x: -data.q.y, y: -data.q.x, z: data.q.z, w: data.q.w)
    }
    
    func detectorCallback(data:Float?) {
        forceLbl.text = "Force: \(String(format: "%.2f", detector.currentForce))"
        rollLbl.text = "Roll: \(String(format: "%.2f", detector.currentRoll))"
        pitchLbl.text = "Pitch: \(String(format: "%.2f", detector.currentPitch))"
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
        }
    }
    
    @IBAction func resetModel(_ sender: UIBarButtonItem) {
        MadgwickAHRSreset()
    }
}
