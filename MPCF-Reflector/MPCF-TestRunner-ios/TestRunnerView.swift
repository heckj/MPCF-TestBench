//
//  TestRunnerView.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import SwiftUI

struct TestRunnerView: View {
    @ObservedObject var testrunner: MPCFTestRunnerModel
    var body: some View {
        VStack {
            MPCFTestControl(testRunnerModel: testrunner)
            Divider()
            MPCFTestStatus(testRunnerModel: testrunner)
        }
    }
}

#if DEBUG
    private func fakeTestRunner() -> MPCFTestRunnerModel {
        let me = MPCFTestRunnerModel(
            peer: MCPeerID(displayName: "livePeer"),
            OTSimpleSpanCollector()
        )
        return me
    }

    struct TestRunnerView_Previews: PreviewProvider {
        static var previews: some View {
            TestRunnerView(testrunner: fakeTestRunner())
        }
    }
#endif
