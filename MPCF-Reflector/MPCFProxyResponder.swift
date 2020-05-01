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


/// protocol description for a trace-enabled MPCF Proxy responder
protocol MPCFProxyResponder: MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    
    var currentAdvertSpan: OpenTelemetry.Span? { get set }
    var mcSession: MCSession? { get set }
    
}
