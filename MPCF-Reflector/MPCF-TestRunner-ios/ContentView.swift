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
        VStack {
            MPCFProxyDisplay(proxy: proxy)
            Text("Span collection size: \(proxy.spanCollector.spanBucket.count)")
            MPCFTestControl(testRunnerModel: proxy.proxyResponder)
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
