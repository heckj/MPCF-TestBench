//
//  MPCFPeerDisplay.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 4/12/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import MultipeerConnectivity
import PreviewBackground

struct MPCFPeerDisplay: View {
    let peer: MCPeerID
    let peerStatus: Bool

    func colorFromStatus() -> Color {
        peerStatus ? Color.green : Color.gray
    }

    var body: some View {
        HStack {
            Circle()
                .fill(colorFromStatus())
            .frame(width: 8, height: 8, alignment: .center)
            Text(peer.displayName)
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
                        MPCFPeerDisplay(peer: MCPeerID(displayName: "livePeer"), peerStatus: true)
                        MPCFPeerDisplay(peer: MCPeerID(displayName: "deadPeer"), peerStatus: false)

                    }
                }
                .environment(\.colorScheme, colorScheme)
                .previewDisplayName("\(colorScheme)")
            }
        }
    }
}
#endif
