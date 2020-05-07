//
//  MPCFTestRunnerModel.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 4/30/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import OpenTelemetryModels

/// Handles the automatic reactions to Multipeer traffic - accepting invitations and responding to any data sent.
class MPCFTestRunnerModel: NSObject, ObservableObject, MPCFProxyResponder {
    internal var currentAdvertSpan: OpenTelemetry.Span?
    @Published var session: MCSession?

    // mechanisms for reflecting the internal session state to UI
    @Published var sessionState: MPCFSessionState = .notConnected
    @Published var connectedPeers: [MCPeerID] = []
    @Published var errorList: [String] = []

    @Published var numberOfTransmissionsSent: Int = 0
    @Published var numberOfTransmissionsRecvd: Int = 0
    @Published var numberOfResourcesRecvd: Int = 0
    @Published var transmissions: [TransmissionIdentifier] = []

    private var spanCollector: OTSimpleSpanCollector
    private var sessionSpans: [MCPeerID: OpenTelemetry.Span] = [:]

    // local temp collection to track spans between starting and finishing recv resource
    private var dataSpans: [MCPeerID: OpenTelemetry.Span] = [:]

    // local lookup that matches spans with explicit transmissions to a reflector
    private var transmissionSpans: [TransmissionIdentifier: OpenTelemetry.Span] = [:]

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: Initializers

    init(spanCollector: OTSimpleSpanCollector) {
        self.spanCollector = spanCollector
    }

    // MARK: State based intializers & SwiftUI exported data views
    @Published var targetPeer: MCPeerID?

    @Published var active = false {
        didSet {
            if active {
                print("Toggled active, starting")
                // compare to the count we have - if we need more
                if Int(numberOfTransmissionsToSend) > xmitLedger.count {
                    // initialize the data, send it, and record it
                    // in our manifest against future responses
                    for _ in 0...(Int(numberOfTransmissionsToSend) - xmitLedger.count) {
                        sendAndRecordTransmission()
                        DispatchQueue.main.asyncAfter(deadline: .now() + transmissionDelay) {
                            // your code here
                        }
                    }
                }
            } else {
                print("Toggled inactive, stopping")
            }
        }
    }

    // kind of stupid that this is a Double, but that's what using a slider
    // in SwiftUI appears to require, so changing here
    @Published var numberOfTransmissionsToSend: Double = 1  // 1, 10, 100
    @Published var transmissionDelay: Double = 0  // in seconds

    // collection of information about data transmissions
    private var xmitLedger: [TransmissionIdentifier: RoundTripXmitReport?] = [:] {
        didSet {
            DispatchQueue.main.async {
                self.transmissions = self.xmitLedger.keys.sorted()
                self.numberOfTransmissionsSent = self.xmitLedger.count
                self.numberOfTransmissionsRecvd =
                    self.xmitLedger.compactMap {
                        $0.value
                    }.count
            }
        }
    }

    @Published var reportsReceived: [RoundTripXmitReport] = []
    var summary: XmitSummary {
        XmitSummary(reportsReceived)
    }

    private func sendAndRecordTransmission() {
        guard let targetPeer = targetPeer, let session = session else {
            // do nothing to send data if there's no target identified
            // or not session defined
            return
        }
        let xmitId = TransmissionIdentifier(traceName: "xmit")
        let envelope = ReflectorEnvelope(id: xmitId, size: .x1k)
        var xmitSpan: OpenTelemetry.Span?
        do {

            xmitSpan = sessionSpans[targetPeer]?.createChildSpan(name: "data xmit")

            // encode, and wrap it in a span
            var encodespan = xmitSpan?.createChildSpan(name: "encode")
            let rawdata = try encoder.encode(envelope)
            encodespan?.finish()
            spanCollector.collectSpan(encodespan)

            // send, and wrap it in a span
            var sessionSendSpan = xmitSpan?.createChildSpan(name: "session.send")
            try session.send(rawdata, toPeers: [targetPeer], with: .reliable)
            sessionSendSpan?.finish()
            spanCollector.collectSpan(sessionSendSpan)

            // record that we sent it, and the span to close it later...
            transmissionSpans[xmitId] = xmitSpan
            xmitLedger[xmitId] = nil
        } catch {
            // TODO: perhaps share notifications of any errors on sending..
            print("Error attempting to encode and send data: ", error)
            DispatchQueue.main.async {
                self.errorList.append(error.localizedDescription)
            }
            xmitLedger[xmitId] = nil
        }
    }

    // MARK: MCNearbyServiceAdvertiserDelegate

    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        // we received an invitation - which we can respond with an MCSession and affirmation to join

        print("received invitation from ", peerID)
        if var currentAdvertSpan = currentAdvertSpan {
            // if we have an avertising span, let's append some events related to the browser on it.
            currentAdvertSpan.addEvent(
                OpenTelemetry.Event(
                    "didReceiveInvitationFromPeer",
                    attr: [OpenTelemetry.Attribute("peerID", peerID.displayName)]))
        }
        // even if we start the invite, we have to also accept the invitation to complete the handshake
        invitationHandler(true, self.session)
    }

    // MARK: MCSessionDelegate methods

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {

        switch state {
        case MCSessionState.connected:
            DispatchQueue.main.async {
                self.sessionState = .connected
                self.connectedPeers = session.connectedPeers
            }
            print("Connected: \(peerID.displayName)")
            print("to peers: ", session.connectedPeers)
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
            DispatchQueue.main.async {
                self.sessionState = .connecting
                self.connectedPeers = session.connectedPeers
            }
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
            DispatchQueue.main.async {
                self.sessionState = .notConnected
                self.connectedPeers = session.connectedPeers
            }
            print("Not Connected: \(peerID.displayName)")
            // and this is the end of a span... I think
            if var sessionSpan = sessionSpans[peerID] {
                sessionSpan.finish()
                spanCollector.collectSpan(sessionSpan)
            }
            // after we "record" it - we kill the current span reference in the dictionary by peer
            sessionSpans.removeValue(forKey: peerID)

        @unknown default:
            fatalError("unsupported MCSessionState result")
        }
    }

    func session(
        _ session: MCSession,
        didReceiveCertificate certificate: [Any]?,
        fromPeer peerID: MCPeerID,
        certificateHandler: @escaping (Bool) -> Void
    ) {
        print("from \(peerID.displayName) received certificate: ", certificate as Any)
        certificateHandler(true)
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // when we're receiving data, it's generally because we've had it reflected back to
        // us from a corresponding reflector. This is the point at which we can mark a signal
        // as complete from having been sent "there and back".
        do {
            let transmissionFinished = Date()
            let foo = try decoder.decode(ReflectorEnvelope.self, from: data)
            let xmitId = foo.id
            if var xmitSpan = transmissionSpans[xmitId] {
                let report = RoundTripXmitReport(
                    start: xmitSpan.startDate(),
                    end: transmissionFinished,
                    dataSize: data.count
                )
                xmitLedger[xmitId] = report
                reportsReceived.append(report)
                xmitSpan.finish(end: transmissionFinished)
                spanCollector.collectSpan(xmitSpan)
                transmissionSpans[xmitId] = nil
                numberOfTransmissionsRecvd += 1
            } else {
                let msgString = "Unable to look up a transmission from: \(xmitId)."
                print(msgString)
                DispatchQueue.main.async {
                    self.errorList.append(msgString)
                }
            }
        } catch {
            print("Error while working with received data: ", error)
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

        if var recvDataSpan = dataSpans[peerID] {
            // complete the span
            recvDataSpan.finish()
            // send it on the collector
            spanCollector.collectSpan(recvDataSpan)
            // clear it from our temp collection
            dataSpans[peerID] = nil
        }

    }

}
