//
//  MPCFPeerDisplay.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 4/12/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import PreviewBackground
import SwiftUI

struct MPCFPeerDisplay: View {
    let peerstatus: MPCFReflectorPeerStatus

    func colorFromStatus() -> Color {
        peerstatus.connected ? Color.green : Color.gray
    }

    var body: some View {
        HStack {
            Circle()
                .fill(colorFromStatus())
                .frame(width: 8, height: 8, alignment: .center)
            Text(peerstatus.peer.displayName).font(.body)
        }
    }
}

#if DEBUG
    struct MPCFPeerDisplay_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    PreviewBackground {
                        VStack {
                            MPCFPeerDisplay(
                                peerstatus: MPCFReflectorPeerStatus(
                                    peer: MCPeerID(displayName: "livePeer"), connected: true))
                            MPCFPeerDisplay(
                                peerstatus: MPCFReflectorPeerStatus(
                                    peer: MCPeerID(displayName: "deadPeer"), connected: false))
                        }
                    }
                    .environment(\.colorScheme, colorScheme)
                    .previewDisplayName("\(colorScheme)")
                }
            }
        }
    }
#endif
