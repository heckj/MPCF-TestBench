//
//  MPCFTestConfig.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/13/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation

final class MPCFTestConfig: ObservableObject, Codable {
    var id: UUID
    @Published var name: String
    @Published var payloadSize: ReflectorEnvelope.PayloadSize
    @Published var dataMode: TransportMode
    @Published var number: UInt
    @Published var delay: Double

    init(
        _ name: String,
        payloadSize: ReflectorEnvelope.PayloadSize = .x1k,
        dataMode: TransportMode = .reliable,
        number: UInt = 1,
        delay: Double = 0.0
    ) {
        id = UUID()
        self.name = name
        self.payloadSize = payloadSize
        self.dataMode = dataMode
        self.number = number
        self.delay = delay
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case payloadSize
        case dataMode
        case number
        case delay
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        payloadSize = try values.decode(ReflectorEnvelope.PayloadSize.self, forKey: .payloadSize)
        dataMode = try values.decode(TransportMode.self, forKey: .dataMode)
        number = try values.decode(UInt.self, forKey: .number)
        delay = try values.decode(Double.self, forKey: .delay)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(payloadSize, forKey: .payloadSize)
        try container.encode(dataMode, forKey: .dataMode)
        try container.encode(number, forKey: .number)
        try container.encode(delay, forKey: .delay)
    }

}
