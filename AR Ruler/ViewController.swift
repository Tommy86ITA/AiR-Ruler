//
//  ViewController.swift
//  AR Ruler
//
//  Created by Thomas Amaranto on 05/04/18.
//  Copyright © 2018 Thomas Amaranto. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
    }
    
    
    //MARK:-    Funzione di creazione dei punti
    
    func addDot(at hitResult : ARHitTestResult) {
        
        let dotGeometry = SCNSphere(radius: 0.005)          // creo la geometria del punto
        let material = SCNMaterial()                        // creo il materiale
        material.diffuse.contents = UIColor.red             // assegno il colore al materiale
        dotGeometry.materials = [material]                  // applico il materiale al punto
        
        let dotNode = SCNNode(geometry: dotGeometry)        // creo il Node del punto
        
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                      hitResult.worldTransform.columns.3.y,
                                      hitResult.worldTransform.columns.3.z)
        // assegno la posizione del punto
        
        sceneView.scene.rootNode.addChildNode(dotNode)      // aggancio il Node al rootNode
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
        
        
    }
    
    //MARK:-    Funzione di calcolo della distanza
    
    func calculate() {
        
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let distance = sqrt(pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)) * 1000
        
        let roundedDistance = round(distance)
        updateText(text: "\(roundedDistance)", atPosition: start.position)
        
    }
    
    //MARK:-    Funzione di creazione del testo 3D
    
    func updateText(text: String, atPosition position: SCNVector3) {
        
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: "\(text) mm", extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        //textGeometry.font = UIFont(name: "Calibri", size: 16)
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        if let camera = sceneView.pointOfView {
            textNode.orientation = camera.orientation
        }
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
    
    
}
