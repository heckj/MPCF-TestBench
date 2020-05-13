//
//  MPCFReflectorPeerStatus.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/12/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct MCPeerAdvertizingStatus: Comparable {
    static func < (lhs: MCPeerAdvertizingStatus, rhs: MCPeerAdvertizingStatus) -> Bool {
        lhs.peer.displayName < rhs.peer.displayName
    }

    let peer: MCPeerID
    let advertising: Bool
}
