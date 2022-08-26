//
//  RoundTripXmitReport.swift
//  MPCF-Reflector-tvOS
//
//  Created by Joseph Heck on 5/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation

struct RoundTripXmitReport: Hashable {
    let sequenceNumber: UInt
    let start: Date
    let end: Date
    let dataSize: Int

    /// returns the bandwidth in bytes/second.
    var bandwidth: Double {
        let duration = start.distance(to: end)
        return Double(dataSize) * 2 / duration
    }
}

extension RoundTripXmitReport: Codable {
    enum CodingKeys: String, CodingKey {
        case num
        case start
        case end
        case datasize

        case bandwidth
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sequenceNumber = try values.decode(UInt.self, forKey: .num)
        start = try values.decode(Date.self, forKey: .start)
        end = try values.decode(Date.self, forKey: .end)
        dataSize = try values.decode(Int.self, forKey: .datasize)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sequenceNumber, forKey: .num)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encode(dataSize, forKey: .datasize)

        try container.encode(bandwidth, forKey: .bandwidth)
    }
}
