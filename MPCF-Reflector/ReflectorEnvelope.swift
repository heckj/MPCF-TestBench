//
//  ReflectorPayload.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 4/17/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation

/// A codable envelope for sample data to be transmitted and recorded for responses while testing.
struct ReflectorEnvelope: Codable {
    let sequenceNumber: UInt
    let tracerID: String
    let timestamp: Date
    let payload: Data

    /// sizing for payloads.
    enum PayloadSize: UInt {
        case x1 = 1
        case x10 = 10
        case x100 = 100
        case x1k = 1024
        case x2k = 2048
        case x4k = 4096
        case x10k = 10240
        case x1M = 1_048_576
    }

    static private var internalSequenceNum: UInt = 0

    /// increments the sequence number for tracking repeated iterations of the same envelope.
    private static func incrementSequence() {
        ReflectorEnvelope.internalSequenceNum += 1
    }

    /// resets the sequence numbers - primarily for testing purposes.
    public static func resetSequence() {
        ReflectorEnvelope.internalSequenceNum = 0
    }

    init(sequenceNumber: UInt, tracerID: String, timestamp: Date, payload: Data) {
        self.payload = payload
        self.tracerID = tracerID
        self.sequenceNumber = sequenceNumber
        self.timestamp = timestamp
    }

    init(tracerID: String, payload: Data) {
        self.payload = payload
        self.tracerID = tracerID
        sequenceNumber = ReflectorEnvelope.internalSequenceNum
        ReflectorEnvelope.incrementSequence()
        timestamp = Date()
    }

    init(tracerID: String, size: PayloadSize) {
        self.tracerID = tracerID
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
        sequenceNumber = ReflectorEnvelope.internalSequenceNum
        ReflectorEnvelope.incrementSequence()
        timestamp = Date()
    }
}
