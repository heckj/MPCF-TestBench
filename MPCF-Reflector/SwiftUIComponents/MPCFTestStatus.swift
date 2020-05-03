//
//  MPCFTestControl.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import PreviewBackground
import SwiftUI

struct MPCFTestStatus: View {
    @ObservedObject var testRunnerModel: MPCFTestRunnerModel
    var body: some View {
        VStack(alignment: .leading) {

            Text("Target: ").font(.headline)
                + Text("\(testRunnerModel.targetPeer?.displayName ?? "???")")
            Divider()
            HStack {
                Text("Sent         ").font(.headline)
                ProgressBar(
                    value: Double(testRunnerModel.transmissionsSent.count),
                    maxValue: testRunnerModel.numberOfTransmissionsToSend
                )
            }

            Divider()
            HStack {
                Text("Received").font(.headline)
                ProgressBar(
                    value: Double(testRunnerModel.transmissionsSent.count),
                    maxValue: Double(testRunnerModel.numberOfTransmissionsRecvd)
                )
            }
            Divider()

        }

    }
}

#if DEBUG
    private func fakeTestRunner() -> MPCFTestRunnerModel {
        let me = MPCFTestRunnerModel(spanCollector: OTSimpleSpanCollector())
        me.targetPeer = MCPeerID(displayName: "livePeer")
        me.numberOfTransmissionsToSend = 100
        me.numberOfTransmissionsRecvd = 69
        return me
    }

    struct MPCFTestStatus_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    PreviewBackground {
                        VStack(alignment: .leading) {
                            MPCFTestStatus(testRunnerModel: fakeTestRunner())
                        }
                    }
                    .environment(\.colorScheme, colorScheme)
                    .environmentObject(MPCFFakes(true))
                    .previewDisplayName("\(colorScheme)")
                }
            }
        }
    }
#endif
