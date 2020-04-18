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

struct SpanHelper {
    static func randomSpanId() -> Data? {
        var keyData = Data(count: 8)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 8, $0.baseAddress!)
        }
        if result == errSecSuccess {
            return keyData
        } else {
            print("Problem generating random bytes")
            return nil
        }
    }
    static func randomTraceId() -> Data? {
        var keyData = Data(count: 16)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 16, $0.baseAddress!)
        }
        if result == errSecSuccess {
            return keyData
        } else {
            print("Problem generating random bytes")
            return nil
        }
    }
    static func spanIdString(_ data: Data) -> String {
        return data.base64EncodedString()
    }
    // I think I really want a "span from another span" helper in here, as well as
    // helpers for creating a local event with a more swifty-interface, and KV attributes
}

class MPCFReflectorProxy: NSObject, ObservableObject, MCNearbyServiceAdvertiserDelegate,
    MCNearbyServiceBrowserDelegate, MCSessionDelegate
{

    let serviceType = "mpcf-reflector"
    var peerID: MCPeerID
    var mcSession: MCSession?
    var advertiser: MCNearbyServiceAdvertiser?
    var browser: MCNearbyServiceBrowser
    @Published var currentAdvertSpan: OpenTelemetry.Span?
    private var sessionSpans: [MCPeerID: OpenTelemetry.Span] = [:]

    private var internalPeerStatusDict: [MCPeerID: MPCFReflectorPeerStatus] = [:] {
        didSet {
            peerList = internalPeerStatusDict.values.sorted()
        }
    }
    @Published var peerList: [MPCFReflectorPeerStatus] = []
    @Published var encryptionPreferences = MCEncryptionPreference.required

    // place to stash all the completed spans...
    @Published var spans: [OpenTelemetry.Span] = []
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
        self.mcSession = MCSession(
            peer: peerID, securityIdentity: nil, encryptionPreference: encryptionPreferences)
        guard let session = self.mcSession else {
            return
        }
        session.delegate = self
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: nil,
            serviceType: serviceType)
        advertiser?.delegate = self
        // create a new Span to reference the advertising - this will also be the parent
        // span to any events or sessions... I hope
        var newSpan = OpenTelemetry.Span()
        newSpan.clearStatus()
        newSpan.traceID = SpanHelper.randomSpanId()!
        newSpan.spanID = SpanHelper.randomSpanId()!
        newSpan.startTimeUnixNano = UInt64(Date().timeIntervalSince1970)
        newSpan.name = "ReflectorServiceAdvertiser"
        currentAdvertSpan = newSpan
        advertiser?.startAdvertisingPeer()
    }

    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        // if we have an advertising span, mark it with an end time and add it to our
        // span collection to report/share later.
        guard var currentSpan = currentAdvertSpan else {
            return
        }
        currentSpan.endTimeUnixNano = UInt64(Date().timeIntervalSince1970)
        spans.append(currentSpan)
        currentAdvertSpan = nil
    }

    // MCNearbyServiceBrowserDelegate

    func browser(
        _ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        print("found peer \(peerID.displayName) - adding")
        if var currentAdvertSpan = currentAdvertSpan {
            // if we have an avertising span, let's append some events related to the browser on it.
            var newEvent = OpenTelemetry.Event()
            newEvent.timeUnixNano = UInt64(Date().timeIntervalSince1970)
            newEvent.name = "foundPeer"
            var newattribute = Opentelemetry_Proto_Common_V1_AttributeKeyValue()
            newattribute.key = "peerID"
            newattribute.stringValue = peerID.displayName
            newEvent.attributes.append(newattribute)
            // grab all the info and convert it into things here too...
            if let info = info {
                for (key, value) in info {
                    var newkv = Opentelemetry_Proto_Common_V1_AttributeKeyValue()
                    newkv.key = key
                    newkv.stringValue = value
                    newEvent.attributes.append(newkv)
                }
            }
            currentAdvertSpan.events.append(newEvent)
        }
        // add to the local peer list as well
        internalPeerStatusDict[peerID] = MPCFReflectorPeerStatus(peer: peerID, connected: true)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer \(peerID.displayName) - marking disabled")
        if var currentAdvertSpan = currentAdvertSpan {
            // if we have an avertising span, let's append some events related to the browser on it.
            var newEvent = OpenTelemetry.Event()
            newEvent.timeUnixNano = UInt64(Date().timeIntervalSince1970)
            newEvent.name = "lostPeer"
            var newattribute = Opentelemetry_Proto_Common_V1_AttributeKeyValue()
            newattribute.key = "peerID"
            newattribute.stringValue = peerID.displayName
            newEvent.attributes.append(newattribute)
            currentAdvertSpan.events.append(newEvent)
        }
        // update the local peer list with the loss info
        internalPeerStatusDict[peerID] = MPCFReflectorPeerStatus(peer: peerID, connected: false)
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("failed to browse for peers: ", error)
    }

    // MCNearbyServiceAdvertiserDelegate

    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        print("received invitation from ", peerID)
        if var currentAdvertSpan = currentAdvertSpan {
            // if we have an avertising span, let's append some events related to the browser on it.
            var newEvent = OpenTelemetry.Event()
            newEvent.timeUnixNano = UInt64(Date().timeIntervalSince1970)
            newEvent.name = "didReceiveInvitationFromPeer"
            var newattribute = Opentelemetry_Proto_Common_V1_AttributeKeyValue()
            newattribute.key = "peerID"
            newattribute.stringValue = peerID.displayName
            newEvent.attributes.append(newattribute)
            currentAdvertSpan.events.append(newEvent)
        }
        // accept all invitations with the default session that we built
        invitationHandler(true, self.mcSession)
    }

    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error
    ) {
        print("failed to advertise: ", error)
    }

    // MCSessionDelegate methods

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            // event in the session span?
            if var sessionSpan = sessionSpans[peerID] {
                var newEvent = OpenTelemetry.Event()
                newEvent.timeUnixNano = UInt64(Date().timeIntervalSince1970)
                newEvent.name = "sessionConnected"
                var newattribute = Opentelemetry_Proto_Common_V1_AttributeKeyValue()
                newattribute.key = "peerID"
                newattribute.stringValue = peerID.displayName
                newEvent.attributes.append(newattribute)
                sessionSpan.events.append(newEvent)
                // not sure if this is needed - I think we may have made a local copy here...
                // so this updates the local collection of spans with our updated version
                sessionSpans[peerID] = sessionSpan
            }

        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            // i think this is the start of the span - but it might be when we recv invitation above...
            if let currentAdvertSpan = currentAdvertSpan {
                var sessionSpan = OpenTelemetry.Span()
                sessionSpan.traceID = currentAdvertSpan.traceID
                sessionSpan.spanID = SpanHelper.randomSpanId()!
                sessionSpan.startTimeUnixNano = UInt64(Date().timeIntervalSince1970)
                // add an attribute of the current peer
                var newattribute = Opentelemetry_Proto_Common_V1_AttributeKeyValue()
                newattribute.key = "peerID"
                newattribute.stringValue = peerID.displayName
                sessionSpan.attributes.append(newattribute)
                sessionSpan.name = "MPCFsession"
                // add it into our collection, referenced by Peer
                sessionSpans[peerID] = sessionSpan
            }

        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
            // and this is the end of a span... I think
            if var sessionSpan = sessionSpans[peerID] {
                sessionSpan.endTimeUnixNano = UInt64(Date().timeIntervalSince1970)
                spans.append(sessionSpan)
            }
            // after we "record" it - we kill the current span reference in the dictionary by peer
            sessionSpans.removeValue(forKey: peerID)

        @unknown default:
            fatalError("unsupported MCSessionState result")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("received data")
        if var sessionSpan = sessionSpans[peerID] {
            var newEvent = OpenTelemetry.Event()
            newEvent.timeUnixNano = UInt64(Date().timeIntervalSince1970)
            newEvent.name = "didReceiveData"
            var newattribute = Opentelemetry_Proto_Common_V1_AttributeKeyValue()
            newattribute.key = "peerID"
            newattribute.stringValue = peerID.displayName
            newEvent.attributes.append(newattribute)
            sessionSpan.events.append(newEvent)
            // not sure if this is needed - I think we may have made a local copy here...
            // so this updates the local collection of spans with our updated version
            sessionSpans[peerID] = sessionSpan
        }
        // I think I want to pop open the data, determine:
        // reliable vs. unreliable transport
        // get a sequence number or identifier of some kind to send back as well
        do {
            try session.send(data, toPeers: [peerID], with: .reliable)
        } catch {
            print("Unexpected error: \(error).")
        }

    }

    func session(
        _ session: MCSession, didReceive stream: InputStream, withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        print("received stream")
    }

    func session(
        _ session: MCSession, didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, with progress: Progress
    ) {
        print("starting receiving resource: \(resourceName)")
        // TODO: create a resource span and link it to the session span...
    }

    func session(
        _ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?
    ) {
        // localURL is a temporarily file with the resource in it
        print("finished receiving resource: \(resourceName)")
        // TODO: complete a resource span and store it away, clearing the in-progress span
        if let tempResourceURL = localURL {
            session.sendResource(at: tempResourceURL, withName: resourceName, toPeer: peerID) {
                (Error) -> Void in
                if let error = Error {
                    print("Unexpected error: \(error).")
                }
            }
        }

    }

}