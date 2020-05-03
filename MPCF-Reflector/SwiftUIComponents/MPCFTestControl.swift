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

struct MPCFTestControl: View {
    @ObservedObject var testRunnerModel: MPCFTestRunnerModel
    var body: some View {
        VStack(alignment: .leading) {

            Text("Number of transmissions to send").font(.headline)
            Slider(
                value: $testRunnerModel.numberOfTransmissionsToSend,
                in: 0...100,
                minimumValueLabel: Text("0"),
                maximumValueLabel: Text("100"),
                label: { EmptyView() }
            )
            Divider()
            Text("Delay between transmissions (in ms)").font(.headline)
            Slider(
                value: $testRunnerModel.transmissionDelay,
                in: 0...2000,
                minimumValueLabel: Text("0"),
                maximumValueLabel: Text("2000"),
                label: { EmptyView() }
            )
        }

    }
}

#if DEBUG
    private func fakeTestRunner() -> MPCFTestRunnerModel {
        let me = MPCFTestRunnerModel(spanCollector: OTSimpleSpanCollector())
        me.targetPeer = MCPeerID(displayName: "livePeer")
        return me
    }

    struct MPCFTestControl_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    PreviewBackground {
                        VStack(alignment: .leading) {
                            MPCFTestControl(testRunnerModel: fakeTestRunner())
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
