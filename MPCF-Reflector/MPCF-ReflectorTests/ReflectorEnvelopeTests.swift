//
//  ReflectorEnvelope.swift
//  MPCF-ReflectorTests
//
//  Created by Joseph Heck on 4/17/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import XCTest
@testable import MPCF_Reflector

class ReflectorEnvelopeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEnvelopeEncode() throws {
        let envelope = ReflectorEnvelope(sequenceNumber: 1, tracerID: "x", timestamp: Date(), payload: Data())

        let jsonEncoded = try JSONEncoder().encode(envelope)
        let plistEncoded = try PropertyListEncoder().encode(envelope)
        XCTAssertGreaterThan(plistEncoded.count, jsonEncoded.count)
    }

    func testJSONEncoderPerformance() throws {
        var bucket: [ReflectorEnvelope] = []
        for num in 1...1000 {
            let envelope = ReflectorEnvelope(sequenceNumber: UInt(num), tracerID: "x", timestamp: Date(), payload: Data())
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
            let envelope = ReflectorEnvelope(sequenceNumber: UInt(num), tracerID: "x", timestamp: Date(), payload: Data())
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
