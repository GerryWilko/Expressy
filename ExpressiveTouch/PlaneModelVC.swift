//
//  PlaneModelVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 18/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class PlaneModelVC: UIViewController {
    private var timer:NSTimer!
    private var scnView:SCNView!
    
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
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
        
//        let axes = [
//            SCNVector3(x: 0, y: 0, z: 0), SCNVector3(x: 1, y: 0, z: 0),
//            SCNVector3(x: 0, y: 0, z: 0), SCNVector3(x: 0, y: 1, z: 0),
//            SCNVector3(x: 0, y: 0, z: 0), SCNVector3(x: 0, y: 0, z: 1)
//        ]
//        
//        let vertexSource = SCNGeometrySource(vertices: axes, count: 6)
//        let indicies = [0, 1, 2]
//        let indexData = NSData(bytes: indicies, length: sizeof(Int) * indicies.count)
//        let element = SCNGeometryElement(data: indexData, primitiveType: SCNGeometryPrimitiveType.Line, primitiveCount: 3, bytesPerIndex: sizeof(Int))
//        let line = SCNGeometry(sources: [vertexSource], elements: [element])
//        let lineNode = SCNNode(geometry: line)
//        scene.rootNode.addChildNode(lineNode)
        
        // set the scene to the view
        scnView.scene = scene 
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        var gestureRecognizers = [AnyObject]()
        gestureRecognizers.append(tapGesture)
        if let existingGestureRecognizers = scnView.gestureRecognizers {
            gestureRecognizers.extend(existingGestureRecognizers)
        }
        scnView.gestureRecognizers = gestureRecognizers
        
        WaxProcessor.getProcessor().dataCache.subscribe(dataCallback)
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        if let hitResults = scnView.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject! = hitResults[0]
                
                // get its material
                let material = result.node!.geometry!.firstMaterial!
                
                // highlight it
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                // on completion - unhighlight
                SCNTransaction.setCompletionBlock {
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(0.5)
                    
                    material.emission.contents = UIColor.blackColor()
                    
                    SCNTransaction.commit()
                }
                
                material.emission.contents = UIColor.redColor()
                
                SCNTransaction.commit()
            }
        }
    }
    
    func dataCallback(data:WaxData) {
        let ship = scnView.scene!.rootNode.childNodeWithName("ship", recursively: true)!
        let scalar:Float = 10.0
        
        ship.orientation = SCNQuaternion(x: -data.q.y, y: -data.q.x, z: data.q.z, w: data.q.w)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    @IBAction func resetModel(sender: UIBarButtonItem) {
        MadgwickAHRSreset()
    }
}