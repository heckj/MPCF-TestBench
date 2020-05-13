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

struct MPCFPeerStatusDisplay: View {
    let peerstatus: MCPeerAdvertizingStatus

    func colorFromStatus() -> Color {
        peerstatus.advertising ? Color.green : Color.gray
    }

    var body: some View {
        HStack {
            Circle()
                .fill(colorFromStatus())
                .frame(width: 11, height: 11, alignment: .center)
                .animation(.default)
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
                        VStack(alignment: .leading) {
                            MPCFPeerStatusDisplay(
                                peerstatus: MCPeerAdvertizingStatus(
                                    peer: MCPeerID(displayName: "livePeer"), advertising: true))
                            MPCFPeerStatusDisplay(
                                peerstatus: MCPeerAdvertizingStatus(
                                    peer: MCPeerID(displayName: "deadPeer"), advertising: false))
                        }
                    }
                    .environment(\.colorScheme, colorScheme)
                    .previewDisplayName("\(colorScheme)")
                }
            }
        }
    }
#endif
