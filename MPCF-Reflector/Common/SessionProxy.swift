//
//  SessionProxy.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/10/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation
import MultipeerConnectivity

/// An observable proxy for when MCSession changes state.
class SessionProxy: NSObject, ObservableObject {
    // session state reflection - these values are updated
    // by the MCSessionDelegate on various callbacks
    @Published var sessionState: MPCFSessionState
    @Published var connectedPeers: [MCPeerID]
    @Published var encryptionPreference: MCEncryptionPreference

    override init() {
        sessionState = .notConnected
        connectedPeers = []
        encryptionPreference = .optional
    }
}
