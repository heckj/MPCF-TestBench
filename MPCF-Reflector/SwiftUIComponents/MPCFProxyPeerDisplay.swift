//
//  ProxyPeerList.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import PreviewBackground
import SwiftUI

struct MPCFProxyPeerDisplay: View {
    @ObservedObject var proxy: MPCFProxy
    var body: some View {
        VStack(alignment: .leading) {
            Text("Known Peers").font(.title)
            List(proxy.peerList, id: \.peer) { peerstatus in
                MPCFPeerStatusDisplay(peerstatus: peerstatus)
            }.animation(.default)
            HStack {
                ForEach(proxy.errorList, id: \.self) { err in
                    Text("\(err)").font(.caption)
                }
            }.animation(.default)
        }
    }
}

#if DEBUG
    private func proxyWithTwoPeers() -> MPCFProxy {
        let x = MPCFProxy(MCPeerID(displayName: "livePeer"))
        x.peerList.append(
            MCPeerAdvertizingStatus(peer: MCPeerID(displayName: "first"), advertising: true)
        )
        x.peerList.append(
            MCPeerAdvertizingStatus(peer: MCPeerID(displayName: "second"), advertising: false)
        )
        return x
    }

    struct MPCFProxyPeerDisplay_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    PreviewBackground {
                        VStack(alignment: .leading) {
                            MPCFProxyPeerDisplay(
                                proxy: proxyWithTwoPeers())
                        }
                    }
                    .environment(\.colorScheme, colorScheme)
                    .previewDisplayName("\(colorScheme)")
                }
            }
        }
    }
#endif
