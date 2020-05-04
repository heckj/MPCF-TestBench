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
                Text("Span collection size: \(proxy.spanCollector.spanBucket.count)")
                MPCFTestControl(testRunnerModel: proxy.proxyResponder as! MPCFTestRunnerModel)
                Divider()
                VStack(alignment: .leading) {
                    Text("Known Peers").font(.body)
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
                                label: { Text("go") }
                            )

                        }
                    }
                }
                Divider()
                //MPCFTestStatus(testRunnerModel: proxy.proxyResponder as! MPCFTestRunnerModel)
            }
        }
    }
}

#if DEBUG
    private func proxyWithRunner() -> MPCFProxy {
        let collector = OTSimpleSpanCollector()
        let runner = MPCFTestRunnerModel(spanCollector: collector)
        runner.targetPeer = MCPeerID(displayName: "livePeer")

        let me = MPCFProxy(
            MCPeerID(displayName: "me"),
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
