//
//  TransmissionIdentifier.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/2/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation
import MultipeerConnectivity

// local, codable mirror to import MultipeerConnectivity.MCSessionSendDataMode
enum TransportMode: UInt, Codable, CustomStringConvertible {
    var description: String {
        switch self {
        case .reliable:
            return "reliable"
        case .unreliable:
            return "unreliable"
        }
    }

    case unreliable = 0
    case reliable = 1
}

struct TransmissionIdentifier: Identifiable, Hashable, Codable, Comparable {

    /// comparable conformance.
    static func < (lhs: TransmissionIdentifier, rhs: TransmissionIdentifier) -> Bool {
        lhs.sequenceNumber < rhs.sequenceNumber
    }

    let id = UUID()
    let sequenceNumber: UInt
    let transport: TransportMode
    let traceName: String
    var sendDataMode: MCSessionSendDataMode {
        switch transport {
        case .unreliable:
            return MCSessionSendDataMode.unreliable
        case .reliable:
            return MCSessionSendDataMode.reliable
        }
    }

    init(traceName: String, transport: TransportMode = .reliable) {
        self.transport = transport
        self.traceName = traceName
        sequenceNumber = TransmissionIdentifier.nextSequenceNumber()
    }

    static private var internalSequenceNum: UInt = 0
    /// increments the sequence number for tracking repeated iterations of the same envelope.
    private static func nextSequenceNumber() -> UInt {
        TransmissionIdentifier.internalSequenceNum += 1
        return internalSequenceNum
    }

    /// resets the sequence numbers - primarily for testing purposes.
    public static func resetSequence() {
        TransmissionIdentifier.internalSequenceNum = 0
    }
}
