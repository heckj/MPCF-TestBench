//
//  RoundTripXmitReport.swift
//  MPCF-Reflector-tvOS
//
//  Created by Joseph Heck on 5/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation

struct RoundTripXmitReport: Hashable {
    let start: Date
    let end: Date
    let dataSize: Int

    /// returns the bandwidth in bytes/second.
    var bandwidth: Double {
        let duration = start.distance(to: end)
        return Double(dataSize) * 2 / duration
    }
}
