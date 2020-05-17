//
//  ContentView.swift
//  MPCF-TestRunner-ios
//
//  Created by Joseph Heck on 4/26/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import SwiftUI

struct MPCFRunnerMainView: View {
    @ObservedObject var proxy: MPCFProxy
    @ObservedObject var runner: MPCFTestRunnerModel
    var body: some View {
        NavigationView {
            VStack {
                MPCFProxyDisplay(advertiseAvailable: false, proxy: proxy)
                    .navigationBarTitle("MPCF Test Runner")
                #if os(macOS) || os(iOS)
                    VStack(alignment: .leading) {
                        Text("Select from available peers to connect:")
                            .font(.body)
                        List(proxy.peerList, id: \.peer) { peerstatus in
                            HStack {
                                MPCFPeerStatusDisplay(peerstatus: peerstatus)
                                    .onTapGesture {
                                        let runner = self.proxy.proxyResponder as! MPCFTestRunnerModel
                                        self.proxy.startSession(with: peerstatus.peer)
                                        runner.targetPeer = peerstatus.peer
                                    }
                            }
                        }
                    }
                #endif
                Divider()
                NavigationLink(
                    destination: MPCFTestConfigurationDisplay(
                        testConfig: self.runner.testconfig),
                    label: {
                        Text("Configure")
                            .font(.headline)
                            .padding(
                                EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(lineWidth: 1)
                            )
                    }
                )
                Divider()
                NavigationLink(
                    destination: MPCFTestRunnerView(
                        testrunner: self.proxy.proxyResponder as! MPCFTestRunnerModel),
                    label: {
                        Text("Transmit")
                            .font(.headline)
                            .padding(
                                EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(lineWidth: 1)
                            )
                    }
                )
                Divider()
                Text("Span collection size: \(proxy.spanCollector.spanCollection.count)")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
    private func proxyWithRunner() -> (MPCFProxy, MPCFTestRunnerModel) {
        let collector = OTSimpleSpanCollector()
        let myself = MCPeerID(displayName: "me")
        let runner = MPCFTestRunnerModel(peer: myself, collector)
        runner.targetPeer = MCPeerID(displayName: "livePeer")

        let me = MPCFProxy(
            myself,
            collector: OTSimpleSpanCollector(),
            encrypt: .required,
            reflectorconfig: false
        )
        me.proxyResponder = runner
        return (me, runner)

    }

    struct MPCFRunnerMainView_Previews: PreviewProvider {
        static var previews: some View {
            MPCFRunnerMainView(proxy: proxyWithRunner().0, runner: proxyWithRunner().1)
        }
    }
#endif
