//
//  ViewController.swift
//  MultipeerConnection
//  Created by Ezgi Özkan 



import UIKit
import MultipeerConnectivity
import SceneKit

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate {
    
    //IBOUtlets

    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
   // @IBOutlet weak var upButton: UIButton
    @IBOutlet weak var sceneView: SCNView!
  
    
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCNearbyServiceAdvertiser!
    
    
    // 2: Add camera node
    let cameraNode = SCNNode()
    
    var centerX: Int = 100
    var strafeDelta: Float = 0.6
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
   
        // 1: Load .obj file
        let scene = SCNScene(named: "converse_obj.obj")
        
        cameraNode.camera = SCNCamera()
        // 3: Place camera
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 35)
    
        // 4: Set camera on scene
        scene?.rootNode.addChildNode(cameraNode)
        
        // 5: Adding light to scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 35)
        scene?.rootNode.addChildNode(lightNode)
        
        // 6: Creating and adding ambien light to scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene?.rootNode.addChildNode(ambientLightNode)
        
        // Allow user to manipulate camera
        sceneView.allowsCameraControl = false

        // Set background color
        sceneView.backgroundColor = UIColor.white
        
        // Allow user translate image
        sceneView.cameraControlConfiguration.allowsTranslation = false
        
        // Set scene settings
        sceneView.scene = scene
        
        
        
        
    }

    // MARK: - Buttons Actions
    
    @IBAction func hostButtonAction(_ sender: Any) {
        startHosting()
    }
    
    @IBAction func guestButtonAction(_ sender: Any) {
        joinSession()
    }
    
   
    
    @IBAction func leftButton(_ sender: Any) {
        
        if (centerX + 1 < 122)
        {
            centerX+=1
            cameraNode.position.x += strafeDelta
           
        }
        
        sendData(data: "\(cameraNode.position.x)")

    }
    
      
    @IBAction func rightButton(_ sender: Any) {
        
        if(centerX - 1 > 90)
        {
            centerX -= 1
            cameraNode.position.x -= strafeDelta
           
        }
       sendData(data: "\(cameraNode.position.x)")
    
    }
    
   /* @IBAction func upButton(_ sender: Any) {
        
        if(centerX - 1 > 90)
        {
            
            centerX -= 1
            cameraNode.position.y += strafeDelta
        }
        
    }*/
    
    
    // MARK: - Functions
    
    //send data to other users
    func sendData(data: String) {
        if mcSession.connectedPeers.count > 0 {
            if let textData = data.data(using: .utf8) {
                do {
                    //send data
                    try mcSession.send(textData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch let error as NSError {
                    //error sending data
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    //start hosting a new room
    func startHosting() {
        mcAdvertiserAssistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "mp-numbers")
        mcAdvertiserAssistant.delegate = self
        mcAdvertiserAssistant.startAdvertisingPeer()
    }
    
    //join a room
    func joinSession() {
        let mcBrowser = MCBrowserViewController(serviceType: "mp-numbers", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    // MARK: - Session Methods
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not connected: \(peerID.displayName)")
            
        @unknown default:
            fatalError()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //data received
        if let text = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async { [self] in
                //display the text in the label
                cameraNode.position.x = Float(text)!
                
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    // MARK: - Browser Methods
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    // MARK: - Advertiser Methods
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        //accept the connection/invitation
        invitationHandler(true, mcSession)
    }
        
}

