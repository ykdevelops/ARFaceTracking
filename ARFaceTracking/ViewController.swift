//
//  ViewController.swift
//  ARFaceTracking
//
//  Created by YoussefKhalil on 2021-02-28.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var bottomLabel: UILabel!
    
    var bottomText = ""
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the scene
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARFaceTrackingConfiguration()
        // Create a session configuration
        
        sceneView.session.run(configuration)
        // Run the view's session
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
       /*
        You can implement this method to provide a new SCNNode object (or instance of an SCNNode subclass)
        containing any attachments you plan to use as a visual representation of the anchor. Note that ARKit
        controls the node's visibility and its transform property, so you may find it useful to add child nodes or adjust
        the node's pivot property to maintain any changes to position or orientation that you make.
        */

        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
         /*
         ARSCNFaceGeometry is a subclass of SCNGeometry that wraps the mesh data provided by the
         ARFaceGeometry class. You can use ARSCNFaceGeometry to quickly and easily visualize face topology and
         facial expressions provided by ARKit in a SceneKit view.
        */
        
        let node = SCNNode(geometry: faceMesh)
        // SCNNode is a structural element of a scene graph, representing a position and transform in a 3D coordinate space.
        
        node.geometry?.firstMaterial?.fillMode = .lines
        // make it lines
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        /*
        Tells the delegate that a SceneKit node's properties have been updated to match the current state of its corresponding anchor.
        renderer : The ARSCNView object rendering the scene
        node : The updated SceneKit node
        anchor : The AR anchor corresponding to the node
         */
        
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
                faceGeometry.update(from: faceAnchor.geometry)
            // everytime the mesh detects an update
            
                readMyFace(anchor: faceAnchor)
                // run readMyFace function
            
                DispatchQueue.main.async { self.bottomLabel.text = self.bottomText }
                // Update the text on the main thread
        }
    }

    func readMyFace(anchor: ARFaceAnchor) {
        // function that takes an ARFaceAnchor in as a parameter
        
        let mouthSmileLeft = anchor.blendShapes[.mouthSmileLeft]
        let mouthSmileRight = anchor.blendShapes[.mouthSmileRight]
        let cheekPuff = anchor.blendShapes[.cheekPuff]
        let tongueOut = anchor.blendShapes[.tongueOut]
        let jawLeft = anchor.blendShapes[.jawLeft]
        let eyeSquintLeft = anchor.blendShapes[.eyeSquintLeft]
        // Define different anchors utilizing classes in the imported kit
        
        self.bottomText = "You are still faced"
        // when this function is running I want to signal to the user that the function is reacting
     
        if ((mouthSmileLeft?.decimalValue ?? 0.0) + (mouthSmileRight?.decimalValue ?? 0.0)) > 0.9 { self.bottomText = "You are smiling. "  }
        // smiling
        if cheekPuff?.decimalValue ?? 0.0 > 0.4 { self.bottomText = "You are puffing your cheeks " }
       // puffy cheeks
        if tongueOut?.decimalValue ?? 0.0 > 0.1 {self.bottomText = "You are sticking your tongue out"}
        // tongue out
        if jawLeft?.decimalValue ?? 0.0 > 0.1 {self.bottomText = "You are moving your jaw to the left"}
        // left jaw
        if eyeSquintLeft?.decimalValue ?? 0.0 > 0.2 {self.bottomText = "You are squinting your left eye"}
        // left eye squint
        // different if statements to update the bottomText based off the facial expression
    }
    
}
