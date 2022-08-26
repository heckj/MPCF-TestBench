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
class MPCFReflectorModel: NSObject, ObservableObject, MPCFProxyResponder {
    // this represents the span matching the MCSession being active
    // it's created when the first invitation is received and event appended
    // as they happen to the delegate.
    var currentSessionSpan: OpenTelemetry.Span?
    var session: MCSession
    var me: MCPeerID

    // mechanisms for reflecting the internal session state to UI
    var sessionProxy: SessionProxy = .init()
    @Published var errorList: [String] = []

    @Published var numberOfTransmissionsRecvd: Int = 0
    @Published var numberOfResourcesRecvd: Int = 0
    @Published var transmissions: [TransmissionIdentifier] = []

    private let decoder = JSONDecoder()

    private var spanCollector: OTSimpleSpanCollector?
    private var dataSpans: [MCPeerID: OpenTelemetry.Span] = [:]

    init(
        peer: MCPeerID,
        _ collector: OTSimpleSpanCollector? = nil,
        _ encryptpref: MCEncryptionPreference = .optional
    ) {
        session = MCSession(
            peer: peer,
            securityIdentity: nil,
            encryptionPreference: encryptpref
        )
        me = peer
        super.init()
        session.delegate = self
        spanCollector = collector
    }

    deinit {}

    // MARK: MCNearbyServiceAdvertiserDelegate

    func advertiser(
        _: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext _: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        print("received invitation from ", peerID)

        if var currentSpan = currentSessionSpan {
            // if we have an avertising span, let's append some events related to the browser on it.
            currentSpan.addEvent(
                OpenTelemetry.Event(
                    "didReceiveInvitationFromPeer",
                    attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)]
                ))
        } else {
            currentSessionSpan = OpenTelemetry.Span.start(name: "sessionStartFromInvitation")
            currentSessionSpan?.addEvent(
                OpenTelemetry.Event(
                    "didReceiveInvitationFromPeer",
                    attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)]
                ))
        }
        // accept all invitations with the default session that we built
        invitationHandler(true, session)
    }

    func advertiser(
        _: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error
    ) {
        print("failed to advertise: ", error)
        currentSessionSpan?.finish(withStatusCode: .internalError)
        DispatchQueue.main.async {
            self.errorList.append(error.localizedDescription)
        }
    }

    // MARK: MCSessionDelegate methods

    func session(
        _: MCSession,
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
            DispatchQueue.main.async {
                self.sessionProxy.sessionState = .connected
                self.sessionProxy.connectedPeers = session.connectedPeers
            }
            print("Connected: \(peerID.displayName)")
            // event in the session span?
            if var sessionSpan = currentSessionSpan {
                sessionSpan.addEvent(
                    OpenTelemetry.Event(
                        "sessionConnected",
                        attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)]
                    ))
            }

        case MCSessionState.connecting:
            DispatchQueue.main.async {
                self.sessionProxy.sessionState = .connecting
                self.sessionProxy.connectedPeers = session.connectedPeers
            }
            print("Connecting: \(peerID.displayName)")
            // i think this is the start of the span - but it might be when we recv invitation above...
            if var sessionSpan = currentSessionSpan {
                sessionSpan.addEvent(
                    OpenTelemetry.Event(
                        "sessionConnecting",
                        attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)]
                    ))
            }

        case MCSessionState.notConnected:
            DispatchQueue.main.async {
                self.sessionProxy.sessionState = .notConnected
                self.sessionProxy.connectedPeers = session.connectedPeers
            }
            print("Not Connected: \(peerID.displayName)")
            // and this is the end of a span... I think
            if var sessionSpan = currentSessionSpan {
                sessionSpan.addEvent(
                    OpenTelemetry.Event(
                        "notConnected",
                        attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)]
                    ))
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
        if var sessionSpan = currentSessionSpan {
            sessionSpan.addEvent(
                OpenTelemetry.Event(
                    "didReceiveData", attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)]
                )
            )
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
                currentSessionSpan?.addEvent(
                    OpenTelemetry.Event(
                        "send", attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)]
                    )
                )
            case .unreliable:
                print("reflecting .unreliable \(data.count) bytes back to \(peerID.displayName)")
                try session.send(data, toPeers: [peerID], with: .unreliable)
                currentSessionSpan?.addEvent(
                    OpenTelemetry.Event(
                        "send", attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)]
                    )
                )
            @unknown default:
                try session.send(data, toPeers: [peerID], with: .reliable)
                print("reflecting .reliable \(data.count) bytes back to \(peerID.displayName)")
                currentSessionSpan?.addEvent(
                    OpenTelemetry.Event(
                        "send", attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)]
                    )
                )
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
        _: MCSession, didReceive _: InputStream, withName _: String,
        fromPeer _: MCPeerID
    ) {
        // DO NOTHING - no stream receipt support
        print("received stream")
    }

    func session(
        _: MCSession, didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, with _: Progress
    ) {
        print("starting receiving resource: \(resourceName)")
        // event in the session span?
        if let sessionSpan = currentSessionSpan {
            var recvDataSpan = sessionSpan.createChildSpan(name: "MPCF-recv-resource")
            // add an attribute of the current peer
            recvDataSpan.setTag("peerID", peerID.displayName)
            // add it into our collection, referenced by Peer
            dataSpans[peerID] = recvDataSpan
        }
    }

    func session(
        _ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, at localURL: URL?, withError _: Error?
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
                Error in
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
