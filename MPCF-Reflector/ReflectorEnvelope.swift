//
//  ReflectorPayload.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 4/17/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation

struct ReflectorEnvelope: Codable {
    let sequenceNumber: UInt
    let tracerID: String
    let timestamp: Date
    let payload: Data
}
