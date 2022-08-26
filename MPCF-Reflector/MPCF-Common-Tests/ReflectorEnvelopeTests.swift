//
//  ReflectorEnvelope.swift
//  MPCF-ReflectorTests
//
//  Created by Joseph Heck on 4/17/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import XCTest

class ReflectorEnvelopeTests: XCTestCase {
    func testEnvelopeEncode() throws {
        let envelope = ReflectorEnvelope(id: TransmissionIdentifier(traceName: "X"), size: .x1k)

        let jsonEncoded = try JSONEncoder().encode(envelope)
        let plistEncoded = try PropertyListEncoder().encode(envelope)
        print("jsonEncoded size is \(jsonEncoded.count)") // 1447
        print("plistEncoded size is \(plistEncoded.count)") // 1150
        XCTAssertGreaterThan(jsonEncoded.count, plistEncoded.count)
    }

    func testJSONEncoderPerformance() throws {
        var bucket: [ReflectorEnvelope] = []
        for _ in 1 ... 1000 {
            let envelope = ReflectorEnvelope(
                id: TransmissionIdentifier(traceName: "X"), payload: Data()
            )
            bucket.append(envelope)
        }

        measure {
            do {
                let _ = try JSONEncoder().encode(bucket)
            } catch {
                print("crap: ", error)
            }
        }
    }

    func testPlistEncoderPerformance() throws {
        var bucket: [ReflectorEnvelope] = []
        for _ in 1 ... 1000 {
            let envelope = ReflectorEnvelope(
                id: TransmissionIdentifier(traceName: "X"), payload: Data()
            )
            bucket.append(envelope)
        }

        measure {
            do {
                let _ = try PropertyListEncoder().encode(bucket)
            } catch {
                print("crap: ", error)
            }
        }
    }
}
