//
//  ReflectorPayload.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 4/17/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation
import MultipeerConnectivity

// local, codable mirror to import MultipeerConnectivity.MCSessionSendDataMode
enum TransportMode: UInt, Codable {
    case unreliable = 0
    case reliable = 1
}

struct TransmissionIdentifier: Identifiable, Hashable, Codable {
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

/// A codable envelope for sample data to be transmitted and recorded for responses while testing.
struct ReflectorEnvelope: Codable {

    let id: TransmissionIdentifier
    let payload: Data

    /// sizing for payloads.
    enum PayloadSize: UInt, Codable {
        case x1 = 1
        case x10 = 10
        case x100 = 100
        case x1k = 1024
        case x2k = 2048
        case x4k = 4096
        case x10k = 10240
        case x1M = 1_048_576
    }

    init(id: TransmissionIdentifier, payload: Data) {
        self.payload = payload
        self.id = id
    }

    init(id: TransmissionIdentifier, size: PayloadSize) {
        self.id = id
        switch size {
        case .x1:
            self.payload = Data(count: Int(PayloadSize.x1.rawValue))
        case .x10:
            self.payload = Data(count: Int(PayloadSize.x10.rawValue))
        case .x100:
            self.payload = Data(count: Int(PayloadSize.x100.rawValue))
        case .x1k:
            self.payload = Data(count: Int(PayloadSize.x1k.rawValue))
        case .x2k:
            self.payload = Data(count: Int(PayloadSize.x10k.rawValue))
        case .x4k:
            self.payload = Data(count: Int(PayloadSize.x4k.rawValue))
        case .x10k:
            self.payload = Data(count: Int(PayloadSize.x10k.rawValue))
        case .x1M:
            self.payload = Data(count: Int(PayloadSize.x1M.rawValue))
        }
    }
}
