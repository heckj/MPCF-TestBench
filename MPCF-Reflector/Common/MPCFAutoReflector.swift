//
//  AutoReflector.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 4/30/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import OpenTelemetryModels

/// Handles the automatic reactions to Multipeer traffic - accepting invitations and responding to any data sent.
class MPCFAutoReflector: NSObject, ObservableObject, MPCFProxyResponder {

    var currentAdvertSpan: OpenTelemetry.Span?
    var session: MCSession?
    var sessionState: MPCFSessionState = .notConnected

    @Published var numberOfTransmissionsRecvd: Int = 0
    @Published var numberOfResourcesRecvd: Int = 0
    @Published var transmissions: [TransmissionIdentifier] = []

    @Published var errorList: [String] = []

    private let decoder = JSONDecoder()

    private var spanCollector: OTSimpleSpanCollector?
    private var sessionSpans: [MCPeerID: OpenTelemetry.Span] = [:]
    private var dataSpans: [MCPeerID: OpenTelemetry.Span] = [:]

    init(_ collector: OTSimpleSpanCollector? = nil) {
        super.init()
        self.spanCollector = collector
    }

    deinit {
    }

    // MARK: MCNearbyServiceAdvertiserDelegate

    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        print("received invitation from ", peerID)
        if var currentAdvertSpan = currentAdvertSpan {
            // if we have an avertising span, let's append some events related to the browser on it.
            currentAdvertSpan.addEvent(
                OpenTelemetry.Event(
                    "didReceiveInvitationFromPeer",
                    attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)]))
        }
        // accept all invitations with the default session that we built
        invitationHandler(true, self.session)
    }

    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error
    ) {
        print("failed to advertise: ", error)
        DispatchQueue.main.async {
            self.errorList.append(error.localizedDescription)
        }
    }

    // MARK: MCSessionDelegate methods

    func session(
        _ session: MCSession,
        didReceiveCertificate certificate: [Any]?,
        fromPeer peerID: MCPeerID,
        certificateHandler: @escaping (Bool) -> Void
    ) {
        print("from \(peerID.displayName) received certificate: ", certificate as Any)
        certificateHandler(true)
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            // event in the session span?
            if var sessionSpan = sessionSpans[peerID] {
                sessionSpan.addEvent(
                    OpenTelemetry.Event(
                        "sessionConnected",
                        attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)]))
                // not sure if this is needed - I think we may have made a local copy here...
                // so this updates the local collection of spans with our updated version
                sessionSpans[peerID] = sessionSpan
            }

        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            // i think this is the start of the span - but it might be when we recv invitation above...
            if let currentAdvertSpan = currentAdvertSpan {
                var sessionSpan = currentAdvertSpan.createChildSpan(name: "MPCFsession")
                // add an attribute of the current peer
                sessionSpan.setTag("peerID", peerID.displayName)
                // add it into our collection, referenced by Peer
                sessionSpans[peerID] = sessionSpan
            }

        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
            // and this is the end of a span... I think
            if var sessionSpan = sessionSpans[peerID] {
                sessionSpan.finish()
                spanCollector?.collectSpan(sessionSpan)
            }
            // after we "record" it - we kill the current span reference in the dictionary by peer
            DispatchQueue.main.async {
                self.sessionSpans.removeValue(forKey: peerID)
            }

        @unknown default:
            fatalError("unsupported MCSessionState result")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("received data")
        DispatchQueue.main.async {
            self.numberOfTransmissionsRecvd += 1
        }
        if var sessionSpan = sessionSpans[peerID] {
            sessionSpan.addEvent(
                OpenTelemetry.Event(
                    "didReceiveData", attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)])
            )
            sessionSpans[peerID] = sessionSpan
        }
        do {
            let xmit = try decoder.decode(ReflectorEnvelope.self, from: data)
            DispatchQueue.main.async {
                self.transmissions.append(xmit.id)
            }
            switch xmit.id.sendDataMode {
            case .reliable:
                print("reflecting .reliable \(data.count) bytes back to \(peerID.displayName)")
                try session.send(data, toPeers: [peerID], with: .reliable)
            case .unreliable:
                print("reflecting .unreliable \(data.count) bytes back to \(peerID.displayName)")
                try session.send(data, toPeers: [peerID], with: .unreliable)
            @unknown default:
                try session.send(data, toPeers: [peerID], with: .reliable)
                print("reflecting .reliable \(data.count) bytes back to \(peerID.displayName)")
            }
            print("data sent, reflection complete")
        } catch {
            print("Unexpected error: \(error).")
            DispatchQueue.main.async {
                self.errorList.append(error.localizedDescription)
            }
        }

    }

    func session(
        _ session: MCSession, didReceive stream: InputStream, withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        // DO NOTHING - no stream receipt support
        print("received stream")
    }

    func session(
        _ session: MCSession, didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, with progress: Progress
    ) {
        print("starting receiving resource: \(resourceName)")
        // event in the session span?
        if let sessionSpan = sessionSpans[peerID] {
            var recvDataSpan = sessionSpan.createChildSpan(name: "MPCF-recv-resource")
            // add an attribute of the current peer
            recvDataSpan.setTag("peerID", peerID.displayName)
            // add it into our collection, referenced by Peer
            dataSpans[peerID] = recvDataSpan
        }
    }

    func session(
        _ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?
    ) {
        // localURL is a temporarily file with the resource in it
        print("finished receiving resource: \(resourceName)")
        numberOfResourcesRecvd += 1
        if var recvDataSpan = dataSpans[peerID] {
            // complete the span
            recvDataSpan.finish()
            // send it on the collector
            spanCollector?.collectSpan(recvDataSpan)
            // clear it from our temp collection
            dataSpans[peerID] = nil
        }

        // since we're the reflector, turn around the send the data immediately back
        // to where it's coming from.
        if let tempResourceURL = localURL {
            session.sendResource(at: tempResourceURL, withName: resourceName, toPeer: peerID) {
                (Error) -> Void in
                if let error = Error {
                    print("Unexpected error: \(error).")
                    DispatchQueue.main.async {
                        self.errorList.append(error.localizedDescription)
                    }
                }
            }
        }

    }
}
