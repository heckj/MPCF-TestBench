//
//  MPCFTestConfigurationDisplay.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/13/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import PreviewBackground
import SwiftUI

#if os(macOS)
    /// proxy the navigationBarTitle into macOS, as it otherwise doesn't exist, to allow for
    /// simpler code reuse.
    extension View {
        func navigationBarTitle(_ title: String) -> some View {
            self
        }
    }
#endif

struct MPCFTestConfigurationDisplay: View {
    @ObservedObject var testConfig: MPCFTestConfig

    #if os(iOS)
        let navStyle = StackNavigationViewStyle()
    #else
        let navStyle = DefaultNavigationViewStyle()
    #endif

    let modes = TransportMode.allCases
    let sendSizes = [
        UInt(1),
        UInt(10),
        UInt(50),
        UInt(100),
        UInt(500),
        UInt(1000),
        UInt(5000),
        UInt(10000),
    ]
    let delayChoices = [
        0.0,
        0.001,
        0.010,
        0.100,
        0.500,
        1.0,
        2.0,
        5.0,
    ]
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Test name: ")
                        TextField("test name", text: $testConfig.name)
                    }
                    Picker("transmission count: ", selection: $testConfig.number) {
                        ForEach(sendSizes, id: \.self) { count in
                            Text(String(count)).tag(count)
                        }
                    }
                    Picker("delay between transmissions: ", selection: $testConfig.delay) {
                        ForEach(delayChoices, id: \.self) { delay in
                            Text("\(delay*1000, specifier: "%.0f") ms").tag(delay)
                        }
                    }
                }
                Section {
                    Picker("Send mode", selection: $testConfig.dataMode) {
                        ForEach(TransportMode.allCases) { v in
                            Text(v.description).tag(v)
                        }
                    }
                    Picker("Data size", selection: $testConfig.payloadSize) {
                        ForEach(ReflectorEnvelope.PayloadSize.allCases) { v in
                            Text(v.name).font(.caption).tag(v)
                        }
                    }
                }
            }
            .navigationBarTitle("Test Configuration")
        }
        .navigationViewStyle(navStyle)
    }
}

#if DEBUG
    private func fakeTestRunner() -> MPCFTestRunnerModel {
        let me = MPCFTestRunnerModel(
            peer: MCPeerID(displayName: "me"),
            OTSimpleSpanCollector()
        )
        return me
    }

    struct MPCFTestConfigurationDisplay_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    PreviewBackground {
                        VStack(alignment: .leading) {
                            MPCFTestConfigurationDisplay(
                                testConfig: fakeTestRunner().testconfig)
                        }
                    }
                    .environment(\.colorScheme, colorScheme)
                    .previewDisplayName("\(colorScheme)")
                }
            }
        }
    }
#endif
