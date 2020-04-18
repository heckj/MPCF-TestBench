//
//  ReflectorEnvelope.swift
//  MPCF-ReflectorTests
//
//  Created by Joseph Heck on 4/17/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import XCTest

@testable import MPCF_Reflector_mac

class ReflectorEnvelopeTests: XCTestCase {

    override func setUp() {
        ReflectorEnvelope.resetSequence()
    }

    func testEnvelopeInitializer() throws {
        let first = ReflectorEnvelope(tracerID: "new", payload: Data())
        let second = ReflectorEnvelope(tracerID: "new", payload: Data())

        XCTAssertEqual(first.sequenceNumber, 0)
        XCTAssertEqual(second.sequenceNumber, 1)

    }

    func testEnvelopeEncode() throws {
        let envelope = ReflectorEnvelope(tracerID: "x", size: .x1k)

        let jsonEncoded = try JSONEncoder().encode(envelope)
        let plistEncoded = try PropertyListEncoder().encode(envelope)
        print("jsonEncoded size is \(jsonEncoded.count)")  // 1447
        print("plistEncoded size is \(plistEncoded.count)")  // 1150
        XCTAssertGreaterThan(jsonEncoded.count, plistEncoded.count)
    }

    func testJSONEncoderPerformance() throws {
        var bucket: [ReflectorEnvelope] = []
        for num in 1...1000 {
            let envelope = ReflectorEnvelope(
                sequenceNumber: UInt(num), tracerID: "x", timestamp: Date(), payload: Data())
            bucket.append(envelope)
        }

        self.measure {
            do {
                let _ = try JSONEncoder().encode(bucket)
            } catch {
                print("crap: ", error)
            }
        }
    }

    func testPlistEncoderPerformance() throws {
        var bucket: [ReflectorEnvelope] = []
        for num in 1...1000 {
            let envelope = ReflectorEnvelope(
                sequenceNumber: UInt(num), tracerID: "x", timestamp: Date(), payload: Data())
            bucket.append(envelope)
        }

        self.measure {
            do {
                let _ = try PropertyListEncoder().encode(bucket)
            } catch {
                print("crap: ", error)
            }
        }
    }

}
