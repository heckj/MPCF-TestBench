//
//  SwiftUIView.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/2/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import PreviewBackground
import SwiftUI

struct MPCFProxyDisplay: View {
    @ObservedObject var proxy: MPCFProxy
    // proxy has a .peerList -> MCPeerStatus
    // .encryptionPreferences
    // proxy.active is Bool
    // $proxy
    var body: some View {
        VStack {
            VStack {
                Text(proxy.peerID.displayName).font(.largeTitle)

                HStack {
                    if proxy.active {
                        Text("Deactivate advertising").foregroundColor(.red)
                    } else {
                        Text("Activate advertising").foregroundColor(.green)
                    }
                    Toggle("active", isOn: $proxy.active).labelsHidden()
                }.padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 2)
                            .foregroundColor(proxy.active ? .green : .gray)
                    )
                MPCFSessionDisplay(session: proxy.proxyResponder?.sessionProxy ?? SessionProxy())
            }
        }
    }
}
#if DEBUG
    private func proxyWithTwoPeers() -> MPCFProxy {
        let x = MPCFProxy(MCPeerID(displayName: "livePeer"))
        x.peerList.append(
            MPCFReflectorPeerStatus(peer: MCPeerID(displayName: "first"), connected: true)
        )
        x.peerList.append(
            MPCFReflectorPeerStatus(peer: MCPeerID(displayName: "second"), connected: false)
        )
        return x
    }

    struct MPCFProxyDisplay_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    PreviewBackground {
                        VStack(alignment: .leading) {
                            MPCFProxyDisplay(
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
