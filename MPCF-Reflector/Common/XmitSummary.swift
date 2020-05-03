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
    var count: Int
    var average: Double
    var median: Double
    var max: Double {
        if let val = rawValues.last {
            return val
        }
        return 0
    }
    var stddev: Double
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
        average = rawValues.avg()
        stddev = rawValues.std()
        median = rawValues[rawValues.count / 2]
    }
}
