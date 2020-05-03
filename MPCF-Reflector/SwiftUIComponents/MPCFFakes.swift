//
//  MPCFFakes.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation

/// A set of fake data to make it easier to mock/overlay data otherwise
/// provided by underlying system frameworks (such as MultipeerConnectivity in this case).
class MPCFFakes: ObservableObject {
    var fakeData = false
    var fakePeerNames = ["peer1", "peer2"]

    init(_ activated: Bool) {
        if activated {
            fakeData = true
        }
    }
}
