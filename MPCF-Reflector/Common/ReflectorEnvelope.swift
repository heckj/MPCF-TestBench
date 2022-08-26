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
    let id: TransmissionIdentifier
    let payload: Data

    /// sizing for payloads.
    enum PayloadSize: UInt, CaseIterable, Hashable, Identifiable, Codable {
        case x1 = 1
        case x10 = 10
        case x100 = 100
        case x1k = 1024
        case x2k = 2048
        case x4k = 4096
        case x10k = 10240
        case x1M = 1_048_576

        var name: String {
            return "\(self)".map {
                $0.isUppercase ? " \($0)" : "\($0)"
            }.joined().capitalized
        }

        var id: PayloadSize { self }
    }

    init(id: TransmissionIdentifier, payload: Data) {
        self.payload = payload
        self.id = id
    }

    init(id: TransmissionIdentifier, size: PayloadSize) {
        self.id = id
        switch size {
        case .x1:
            payload = Data(count: Int(PayloadSize.x1.rawValue))
        case .x10:
            payload = Data(count: Int(PayloadSize.x10.rawValue))
        case .x100:
            payload = Data(count: Int(PayloadSize.x100.rawValue))
        case .x1k:
            payload = Data(count: Int(PayloadSize.x1k.rawValue))
        case .x2k:
            payload = Data(count: Int(PayloadSize.x10k.rawValue))
        case .x4k:
            payload = Data(count: Int(PayloadSize.x4k.rawValue))
        case .x10k:
            payload = Data(count: Int(PayloadSize.x10k.rawValue))
        case .x1M:
            payload = Data(count: Int(PayloadSize.x1M.rawValue))
        }
    }
}
