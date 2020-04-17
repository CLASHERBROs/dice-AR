//
//  ViewController.swift
//  Diceey-AR
//
//  Created by paritosh on 17/04/20.
//  Copyright © 2020 paritosh. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    var diceArray = [SCNNode]()
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: -Configuration and debugg options
      //  self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]//shows feature points a way to debug
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true //enables lighting
        // Show statistics such as fps and timing information
        //  sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal //enum detects horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    //MARK: - SENSING USER TOUCH
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { //to detect touches
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlane)
            if let hitResult = results.first{
                print(hitResult)
              //MARK: - PUTTING IN DICE
                let scene = SCNScene(named: "art.scnassets/dice.scn")!
                if let diceNode = scene.rootNode.childNode(withName: "Dice", recursively: true)
                {  diceNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x,     y:hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius, z: hitResult.worldTransform.columns.3.z)//will display line at this posn
                    
                    // Set the scene to the view
                    diceArray.append(diceNode)
                    sceneView.scene.rootNode.addChildNode(diceNode)
                   roll(diceNode)
               
                    
                }
                
            }
            
            
        }
    } //MARK: -rotate all the dices present in the view
    func rollAll(){
        if !diceArray.isEmpty{
            for dice in diceArray {
                roll(dice)
            }
        }
    }
     //MARK: -ROTATE THE DICE
    func roll(_ dice:SCNNode){
        let randomX = Float(arc4random_uniform(4)+1) * (Float.pi/2)  // random number b/w 1...4
                    let randomZ = Float(arc4random_uniform(4)+1) * (Float.pi/2)
                        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX*5), y: 0, z: CGFloat(randomZ*5),  duration: 0.5))  //*5 for more maza
    }
    //MARK: -Adding plane in the form of grid for horizontal area
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {//anchor is basically a tile used to place objects
        if(anchor is ARPlaneAnchor){
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))   //shows plane object will be displayed
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)  //about what axis to be rotated
          //MARK: -Show Grid
            // let gridMaterial = SCNMaterial()   // uncomment to show grid
           // gridMaterial.diffuse.contents = UIImage(named: "grid")
           // plane.materials = [gridMaterial]
           let clearMaterial = SCNMaterial()
            clearMaterial.diffuse.contents = UIColor.clear//comment to show grid
            plane.materials = [clearMaterial]//comment to show grid
            planeNode.geometry = plane
            node.addChildNode(planeNode)
            
        }
        else {
            return
        }
    }
    
    @IBAction func rollButtonPressed(_ sender: UIBarButtonItem) {
        rollAll()
    }
    //MARK: - rotate on shaking
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func deleteButton(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty{
            for dice in diceArray{
                dice.removeFromParentNode()
            }
            diceArray.removeAll()
        }
    }
    
}
