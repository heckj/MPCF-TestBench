//
//  ContentView.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 4/12/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import SwiftUI

struct ContentView: View {
    @ObservedObject var proxy: MPCFProxy
    var body: some View {
        VStack {
            MPCFProxyDisplay(proxy: proxy)
            Divider()
            MPCFProxyPeerDisplay(proxy: proxy)
            Divider()
            Text("Span collection size: \(proxy.spanCollector.spanCollection.count)")
            Divider()
            MPCFReflectorStatus(reflector: proxy.proxyResponder as! MPCFReflectorModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(proxy: MPCFProxy(MCPeerID(displayName: "xpeer")))
    }
}
