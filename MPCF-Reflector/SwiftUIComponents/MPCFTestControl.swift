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

            HStack {
                Text("Send").font(.body)
                Text("\(testRunnerModel.numberOfTransmissionsToSend, specifier: "%.0f")")
                Slider(
                    value: $testRunnerModel.numberOfTransmissionsToSend,
                    in: 1...1000,
                    minimumValueLabel: Text(""),
                    maximumValueLabel: Text("1000"),
                    label: { EmptyView() }
                )
            }
            Divider()
            HStack {
                Text("Delay").font(.body)
                Text("\(testRunnerModel.transmissionDelay, specifier: "%.2f")")
                Slider(
                    value: $testRunnerModel.transmissionDelay,
                    in: 0...2,
                    step: 0.5,
                    minimumValueLabel: Text(""),
                    maximumValueLabel: Text("2"),
                    label: { EmptyView() }
                )
            }
            VStack {
                Divider()
                HStack {
                    if testRunnerModel.active {
                        Text("Deactivate Test").foregroundColor(.red)
                    } else {
                        Text("Activate Test").foregroundColor(.green)
                    }

                    Toggle("active", isOn: $testRunnerModel.active).labelsHidden()
                }.padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 2)
                            .foregroundColor(testRunnerModel.active ? .green : .gray)
                    )
            }

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
                    .previewDisplayName("\(colorScheme)")
                }
            }
        }
    }
#endif
