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

    var proxyResponder: MPCFProxyResponder?
    var spanCollector: OTSpanCollector

    var advertisingSpan: OpenTelemetry.Span?
    var browsingSpan: OpenTelemetry.Span

    private var internalPeerStatusDict: [MCPeerID: MCPeerAdvertizingStatus] = [:] {
        didSet {
            peerList = internalPeerStatusDict.values.sorted()
        }
    }

    @Published var peerList: [MCPeerAdvertizingStatus] = []
    @Published var encryptionPreferences: MCEncryptionPreference
    @Published var errorList: [String] = []

    // place to stash all the completed spans...
    // @Published var spans: [OpenTelemetry.Span] = []
    @Published var active = false {
        didSet {
            if active {
                print("Toggled active, starting")
                startAdvertising()
            } else {
                print("Toggled inactive, stopping")
                stopAdvertising()
            }
        }
    }

    init(
        _ peerID: MCPeerID,
        collector: OTSimpleSpanCollector? = nil,
        encrypt: MCEncryptionPreference = .optional,
        reflectorconfig: Bool = true
    ) {
        self.peerID = peerID
        if let collector = collector {
            spanCollector = collector
        } else {
            spanCollector = OTSimpleSpanCollector()
        }
        encryptionPreferences = encrypt
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browsingSpan = OpenTelemetry.Span.start(name: "MCNearbyServiceBrowser")
        super.init()
        if reflectorconfig {
            proxyResponder = MPCFReflectorModel(peer: peerID, collector)
        }
        browser.delegate = self
        browser.startBrowsingForPeers()
    }

    deinit {}

    func terminateBrowsing() {
        browser.stopBrowsingForPeers()
        browsingSpan.finish()
        spanCollector.collectSpan(browsingSpan)
    }

    /// I could pass the session and advertising delegate in through here...
    func startAdvertising() {
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        advertiser?.delegate = proxyResponder
        // create a new Span to reference the advertising - this will also be the parent
        // span to any events or sessions... I hope
        advertisingSpan = OpenTelemetry.Span.start(
            name: "MPCFServiceAdvertiser")
        advertiser?.startAdvertisingPeer()
    }

    func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
        // if we have an advertising span, mark it with an end time and add it to our
        // span collection to report/share later.
        guard var currentSpan = advertisingSpan else {
            return
        }
        currentSpan.finish()
        spanCollector.collectSpan(currentSpan)
        advertisingSpan = nil
    }

    func startSession(with peerID: MCPeerID) {
        print("inviting multipeer connection with ", peerID.displayName)
        guard let responder = proxyResponder else {
            return
        }
        // if we have an avertising span, let's append some events related to the browser on it.
        responder.currentSessionSpan = OpenTelemetry.Span.start(
            name: "startSession", attr: [OpenTelemetry.Attribute("withPeerID", peerID.displayName)]
        )

        // to initiate an invite, you use the following on the MCNearbyServiceBrowser:
        browser.invitePeer(peerID, to: responder.session, withContext: nil, timeout: 5.0)
    }

    // MARK: MCNearbyServiceBrowserDelegate

    func browser(
        _: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        print("found peer \(peerID.displayName) - adding")
        var attrList: [OpenTelemetry.Attribute] = [
            OpenTelemetry.Attribute("peerID", peerID.displayName),
        ]
        // grab all the info and convert it into things here too...
        if let info = info {
            for (key, value) in info {
                attrList.append(OpenTelemetry.Attribute(key, value))
            }
        }
        browsingSpan.addEvent(OpenTelemetry.Event("foundPeer", attr: attrList))

        // add to the local peer list as well
        internalPeerStatusDict[peerID] = MCPeerAdvertizingStatus(peer: peerID, advertising: true)
    }

    func browser(_: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer \(peerID.displayName) - marking disabled")

        browsingSpan.addEvent(
            OpenTelemetry.Event(
                "lostPeer", attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)]
            ))

        // update the local peer list with the loss info
        internalPeerStatusDict[peerID] = MCPeerAdvertizingStatus(peer: peerID, advertising: false)
    }

    func browser(_: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("failed to browse for peers: ", error)
        browsingSpan.finish(withStatusCode: .internalError)
        errorList.append(error.localizedDescription)
    }
}
