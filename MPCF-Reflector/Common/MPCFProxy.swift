//
//  MPCF-ReflectorProxy.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 4/12/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import OpenTelemetryModels

struct MPCFReflectorPeerStatus: Comparable {
    static func < (lhs: MPCFReflectorPeerStatus, rhs: MPCFReflectorPeerStatus) -> Bool {
        lhs.peer.displayName < rhs.peer.displayName
    }

    let peer: MCPeerID
    let connected: Bool
}

/// The rough moral equivalent of the Transceiver concept in MultiPeerKit's mechanism.
///
/// Send and receive data, object of responsibility.
/// I'm additionally making it an Observable object to be able to expose the information about
/// it's state via SwiftUI.
class MPCFProxy: NSObject, ObservableObject, MCNearbyServiceBrowserDelegate {

    let serviceType = "mpcf-reflector"
    var peerID: MCPeerID
    var advertiser: MCNearbyServiceAdvertiser?
    var browser: MCNearbyServiceBrowser
    var session: MCSession

    var proxyResponder: MPCFProxyResponder?
    var spanCollector: OTSimpleSpanCollector

    private var internalPeerStatusDict: [MCPeerID: MPCFReflectorPeerStatus] = [:] {
        didSet {
            peerList = internalPeerStatusDict.values.sorted()
        }
    }
    @Published var peerList: [MPCFReflectorPeerStatus] = []
    @Published var encryptionPreferences: MCEncryptionPreference

    // place to stash all the completed spans...
    //@Published var spans: [OpenTelemetry.Span] = []
    @Published var active = false {
        didSet {
            if active {
                print("Toggled active, starting")
                self.startHosting()
            } else {
                print("Toggled inactive, stopping")
                self.stopHosting()
            }
        }
    }

    init(
        _ peerID: MCPeerID,
        collector: OTSimpleSpanCollector? = nil,
        encrypt: MCEncryptionPreference = .required,
        reflectorconfig: Bool = true
    ) {
        self.peerID = peerID
        if let collector = collector {
            self.spanCollector = collector
        } else {
            self.spanCollector = OTSimpleSpanCollector()
        }
        self.encryptionPreferences = encrypt
        self.session = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: encrypt)
        self.browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        super.init()
        if reflectorconfig {
            proxyResponder = MPCFAutoReflector(collector)
        }
        self.browser.delegate = self
        self.browser.startBrowsingForPeers()
    }

    deinit {
        self.browser.stopBrowsingForPeers()
    }

    /// I could pass the session and advertising delegate in through here...
    func startHosting() {
        if let responder = proxyResponder {
            responder.session = self.session
            session.delegate = proxyResponder
        }
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: nil,
            serviceType: serviceType)
        advertiser?.delegate = proxyResponder
        // create a new Span to reference the advertising - this will also be the parent
        // span to any events or sessions... I hope
        proxyResponder?.currentAdvertSpan = OpenTelemetry.Span.start(
            name: "ReflectorServiceAdvertiser")
        advertiser?.startAdvertisingPeer()
    }

    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        // if we have an advertising span, mark it with an end time and add it to our
        // span collection to report/share later.
        guard var currentSpan = proxyResponder?.currentAdvertSpan else {
            return
        }
        currentSpan.finish()
        spanCollector.collectSpan(currentSpan)
        proxyResponder?.currentAdvertSpan = nil
    }

    // MARK: MCNearbyServiceBrowserDelegate

    func browser(
        _ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        print("found peer \(peerID.displayName) - adding")
        if var currentAdvertSpan = proxyResponder?.currentAdvertSpan {
            // if we have an avertising span, let's append some events related to the browser on it.
            var attrList: [OpenTelemetry.Attribute] = [
                OpenTelemetry.Attribute("peerID", peerID.displayName)
            ]
            // grab all the info and convert it into things here too...
            if let info = info {
                for (key, value) in info {
                    attrList.append(OpenTelemetry.Attribute(key, value))
                }
            }
            currentAdvertSpan.addEvent(OpenTelemetry.Event("foundPeer", attr: attrList))
        }
        // add to the local peer list as well
        internalPeerStatusDict[peerID] = MPCFReflectorPeerStatus(peer: peerID, connected: true)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer \(peerID.displayName) - marking disabled")
        if var currentAdvertSpan = proxyResponder?.currentAdvertSpan {
            // if we have an avertising span, let's append some events related to the browser on it.
            currentAdvertSpan.addEvent(
                OpenTelemetry.Event(
                    "lostPeer", attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)]))
        }
        // update the local peer list with the loss info
        internalPeerStatusDict[peerID] = MPCFReflectorPeerStatus(peer: peerID, connected: false)
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("failed to browse for peers: ", error)
    }

    func startSession(with peerID: MCPeerID) {
        // if we have an avertising span, let's append some events related to the browser on it.
        proxyResponder?.currentAdvertSpan?.addEvent(
            OpenTelemetry.Event(
                "invitePeer",
                attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)]))

        // to initiate an invite, you use the following on the MCNearbyServiceBrowser:
        self.browser.invitePeer(peerID, to: session, withContext: nil, timeout: 5.0)
    }

}
