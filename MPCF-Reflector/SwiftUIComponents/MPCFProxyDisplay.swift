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

                VStack {
                    if proxy.active {
                        Text("Deactivate").foregroundColor(.red)
                    } else {
                        Text("Activate").foregroundColor(.green)
                    }

                    Toggle("active", isOn: $proxy.active).labelsHidden()
                }.padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 2)
                            .foregroundColor(proxy.active ? .green : .gray)
                    )

            }

            VStack(alignment: .leading) {
                MPCFSessionDisplay(
                    session: proxy.session,
                    sessionState: proxy.proxyResponder?.sessionState ?? .notConnected
                )
                Text("Known Peers").font(.title)
                List(proxy.peerList, id: \.peer) { peerstatus in
                    MPCFPeerStatusDisplay(peerstatus: peerstatus)
                }
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
        // x.active = true
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
                    .environmentObject(MPCFFakes(true))
                    .previewDisplayName("\(colorScheme)")
                }
            }
        }
    }
#endif
