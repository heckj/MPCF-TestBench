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
            Text("I am: \(proxy.peerID.displayName)")
            Spacer()
            List(proxy.peerList, id: \.peer) { peerstatus in
                MPCFPeerDisplay(peerstatus: peerstatus)
            }
            Spacer()
            Toggle(isOn: $proxy.active, label: { Text("enable") })
        }
    }
}
#if DEBUG
    struct MPCFProxyDisplay_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    PreviewBackground {
                        VStack {
                            MPCFProxyDisplay(
                                proxy: MPCFProxy(MCPeerID(displayName: "livePeer")))
                        }
                    }
                    .environment(\.colorScheme, colorScheme)
                    .previewDisplayName("\(colorScheme)")
                }
            }
        }
    }
#endif
