//
//  TransmissionIdentifierTests.swift
//  MPCF-Common-Tests
//
//  Created by Joseph Heck on 5/2/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import XCTest

class TransmissionIdentifierTests: XCTestCase {

    override func setUpWithError() throws {
        TransmissionIdentifier.resetSequence()
    }

    func testXmitIdInitializer() throws {
        let first = TransmissionIdentifier(traceName: "first")
        let second = TransmissionIdentifier(traceName: "second")

        XCTAssertEqual(first.sequenceNumber, 1)
        XCTAssertEqual(second.sequenceNumber, 2)

    }

}
