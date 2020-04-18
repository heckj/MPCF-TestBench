//
//  MPCF-ReflectorProxy.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 4/12/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import OrderedDictionary

struct MPCFReflectorPeerStatus: Comparable {
    static func < (lhs: MPCFReflectorPeerStatus, rhs: MPCFReflectorPeerStatus) -> Bool {
        lhs.peer.displayName < rhs.peer.displayName
    }

    let peer: MCPeerID
    let connected: Bool
}

class MPCFReflectorProxy : NSObject, ObservableObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {

    let serviceType = "mpcf-reflector"
    var peerID: MCPeerID
    var mcSession: MCSession?
    var advertiser: MCNearbyServiceAdvertiser?
    var browser: MCNearbyServiceBrowser

    private var internalPeerStatusDict: [MCPeerID:MPCFReflectorPeerStatus] = [:] {
        didSet {
            peerList = internalPeerStatusDict.values.sorted()
        }
    }
    @Published var peerList: [MPCFReflectorPeerStatus] = []
    @Published var encryptionPreferences = MCEncryptionPreference.required

    @Published var active = false {
        didSet {
            if (active) {
                print("Toggled active, starting")
                self.startHosting()
            } else {
                print("Toggled inactive, stopping")
                self.stopHosting()
            }
        }
    }

    init(_ peerID: MCPeerID) {
        self.peerID = peerID
        self.browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        super.init()
        self.browser.delegate = self
        self.browser.startBrowsingForPeers()
    }

    deinit {
        self.browser.stopBrowsingForPeers()
    }
    
    func startHosting() {
        self.mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: encryptionPreferences)
        guard let session = self.mcSession else {
            return
        }
        session.delegate = self
        advertiser = MCNearbyServiceAdvertiser(peer: peerID,
                                               discoveryInfo: nil,
                                               serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
    }

    // MCNearbyServiceBrowserDelegate

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("found peer \(peerID.displayName) - adding")
        internalPeerStatusDict[peerID] = MPCFReflectorPeerStatus(peer: peerID, connected: true)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer \(peerID.displayName) - marking disabled")
        internalPeerStatusDict[peerID] = MPCFReflectorPeerStatus(peer: peerID, connected: false)
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("failed to browse for peers: ", error)
    }

    // MCNearbyServiceAdvertiserDelegate

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("received invitation from ", peerID)
        // accept all invitations with the default session that we built
        invitationHandler(true, self.mcSession)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("failed to advertise: ", error)
    }

    // MCSessionDelegate methods

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")

        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")

        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        @unknown default:
            fatalError("unsupported MCSessionState result")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("received data")
        // I think I want to pop open the data, determine:
        // reliable vs. unreliable transport
        // get a sequence number or identifier of some kind to send back as well
        do {
            try session.send(data, toPeers: [peerID], with: .reliable)
        } catch {
            print("Unexpected error: \(error).")
        }

    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("received stream")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("starting receiving resource: \(resourceName)")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // localURL is a temporarily file with the resource in it
        print("finished receiving resource: \(resourceName)")
        if let tempResourceURL = localURL {
            session.sendResource(at: tempResourceURL, withName: resourceName, toPeer: peerID) { (Error) -> Void in
                if let error = Error {
                    print("Unexpected error: \(error).")
                }
            }
        }

    }

}
