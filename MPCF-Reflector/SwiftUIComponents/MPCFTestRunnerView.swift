//
//  TestRunnerView.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import SwiftUI

struct MPCFTestRunnerView: View {
    @ObservedObject var testrunner: MPCFTestRunnerModel
    func targetSelected() -> Bool {
        testrunner.targetPeer != nil
    }

    func runTest() {
        testrunner.sendTransmissions()
    }

    var body: some View {
        VStack {
            MPCFSessionDisplay(session: testrunner.sessionProxy)
            if self.targetSelected() {
                Divider()
                Button(action: runTest) {
                    Text("RUN")
                }
            }
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
            MPCFTestRunnerView(testrunner: fakeTestRunner())
        }
    }
#endif
