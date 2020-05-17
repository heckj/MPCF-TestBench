//
//  XmitSummary.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation

extension Array where Element: FloatingPoint {
    func sum() -> Element {
        return self.reduce(0, +)
    }

    func avg() -> Element {
        return self.sum() / Element(self.count)
    }

    func std() -> Element {
        let mean = self.avg()
        let v = self.reduce(0, { $0 + ($1 - mean) * ($1 - mean) })
        return sqrt(v / (Element(self.count) - 1))
    }
}

struct XmitSummary {
    var count: Int = 0
    var average: Double = 0
    var median: Double = 0
    var max: Double {
        if let val = rawValues.last {
            return val
        }
        return 0
    }
    var stddev: Double = 0
    var rawValues: [Double]
    var ntile90: Double? {
        if rawValues.count > 9 {
            let location = 0.9 * Double(rawValues.count)
            return rawValues[Int(location)]
        }
        return nil
    }
    var ntile95: Double? {
        if rawValues.count > 19 {  // 95 percentile
            let location = 0.9 * Double(rawValues.count)
            return rawValues[Int(location)]
        }
        return nil
    }
    var ntile99: Double? {
        if rawValues.count > 99 {  // 99 percentile
            let location = 0.9 * Double(rawValues.count)
            return rawValues[Int(location)]
        }
        return nil
    }
    var ntile999: Double? {
        if rawValues.count > 999 {  // 99.9 percentile
            let location = 0.9 * Double(rawValues.count)
            return rawValues[Int(location)]
        }
        return nil
    }

    init(_ list: [RoundTripXmitReport]) {
        rawValues = list.map { $0.bandwidth }.sorted()
        count = rawValues.count
        if count == 1 {
            self.median = self.rawValues[0]
        } else if count > 1 {
            self.median = rawValues[rawValues.count / 2]
            average = rawValues.avg()
            stddev = rawValues.std()
        }
    }
}

extension XmitSummary: Encodable {
    enum CodingKeys: String, CodingKey {
        case count
        case average
        case median
        case max
        case stddev

        case ntile90
        case ntile95
        case ntile99
        case ntile999
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(count, forKey: .count)
        try container.encode(average, forKey: .average)
        try container.encode(median, forKey: .median)
        try container.encode(max, forKey: .max)

        try container.encode(stddev, forKey: .stddev)
        try container.encode(ntile90, forKey: .ntile90)
        try container.encode(ntile95, forKey: .ntile95)
        try container.encode(ntile99, forKey: .ntile99)
        try container.encode(ntile999, forKey: .ntile999)
    }

}
