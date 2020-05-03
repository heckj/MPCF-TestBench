//
//  MPCFProxyResponder.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 4/30/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import OpenTelemetryModels

/// enumeration to expose the changing state of the session while in use.
/// otherwise it's really only available as callbacks to the MCSessionDelegate.
enum MPCFSessionState: String, Codable {
    case notConnected = "not connected"
    case connecting = "connecting"
    case connected = "connected"
}

/// protocol description for a trace-enabled MPCF Proxy responder.
protocol MPCFProxyResponder: MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {

    var currentAdvertSpan: OpenTelemetry.Span? { get set }
    var session: MCSession? { get set }
    var sessionState: MPCFSessionState { get set }

}
