//
//  ContentView.swift
//  MPCF-Reflector-mac
//
//  Created by Joseph Heck on 4/18/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import SwiftUI

struct MPCFReflectorMainView: View {
    @ObservedObject var proxy: MPCFProxy

    #if os(iOS)
        let navStyle = StackNavigationViewStyle()
    #else
        let navStyle = DefaultNavigationViewStyle()
    #endif

    var body: some View {
        NavigationView {
            VStack {
                MPCFProxyDisplay(advertiseAvailable: true, proxy: proxy)
                Divider()
                MPCFProxyPeerDisplay(proxy: proxy)
                Divider()
                Text("Span collection size: \(proxy.spanCollector.spanCollection.count)")
                Divider()
                MPCFReflectorStatus(reflector: proxy.proxyResponder as! MPCFReflectorModel)
            }
            .navigationBarTitle("MPCF Reflector")
        }
        .navigationViewStyle(navStyle)
    }
}

struct MPCFReflectorMainView_Previews: PreviewProvider {
    static var previews: some View {
        MPCFReflectorMainView(proxy: MPCFProxy(MCPeerID(displayName: "xpeer")))
    }
}
