//
//  ContentView.swift
//  MPCF-TestRunner-ios
//
//  Created by Joseph Heck on 4/26/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import SwiftUI

struct ContentView: View {
    @ObservedObject var proxy: MPCFProxy
    var body: some View {
        NavigationView {
            VStack {
                MPCFProxyDisplay(proxy: proxy)
                Divider()
                Text("Span collection size: \(proxy.spanCollector.spanCollection.count)")
                Divider()
                VStack(alignment: .leading) {
                    Text("Available Peers").font(.body)
                    List(proxy.peerList, id: \.peer) { peerstatus in
                        HStack {
                            MPCFPeerStatusDisplay(peerstatus: peerstatus)
                                .onTapGesture {
                                    let runner = self.proxy.proxyResponder as! MPCFTestRunnerModel
                                    self.proxy.startSession(with: peerstatus.peer)
                                    runner.targetPeer = peerstatus.peer
                                }

                            NavigationLink(
                                destination: TestRunnerView(
                                    testrunner: self.proxy.proxyResponder as! MPCFTestRunnerModel),
                                label: { Text("transmit") }
                            )

                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
    private func proxyWithRunner() -> MPCFProxy {
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
        return me

    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView(proxy: proxyWithRunner())
        }
    }
#endif
