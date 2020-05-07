//
//  MPCFSessionDisplay.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import PreviewBackground
import SwiftUI

struct MPCFSessionDisplay: View {
    let responder: MPCFProxyResponder

    /// Exposes the colorscheme in this view so we can make
    /// choices based on it.
    @Environment(\.colorScheme) public var colorSchemeMode

    /// Creates the "inverse" of .primary so that I can display constrasting
    /// colors with overlays, but still respect the dark/light mode construction.
    /// - Returns: Color.black or Color.white.
    func invertedPrimaryColor() -> Color {
        if colorSchemeMode == .dark {
            return Color.black
        } else {
            return Color.white
        }
    }

    private func connectedSession() -> Bool {
        responder.sessionState == .connected
    }

    private func encryptedSession() -> Bool {
        responder.session?.encryptionPreference == .required
    }

    private func connectedPeerStrings() -> [String] {
        return responder.connectedPeers.map {
            $0.displayName
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if encryptedSession() {
                    Image(systemName: "lock")
                } else {
                    Image(systemName: "lock.slash")
                }
                Text("(ME): \(responder.sessionState.rawValue)")
                ForEach(connectedPeerStrings(), id: \.self) { displayname in
                    Text(displayname)
                        .hidden()
                        .overlay(
                            Capsule(style: .continuous).overlay(
                                Text(displayname)
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(self.invertedPrimaryColor())
                            )
                        )
                }
            }
        }
    }
}

#if DEBUG
    private func fakeResponder() -> MPCFProxyResponder {
        let me = MCPeerID(displayName: "thisPeer")
        let autoresponder = MPCFAutoReflector()
        autoresponder.session = MCSession(
            peer: me,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        autoresponder.sessionState = .connected
        autoresponder.connectedPeers.append(MCPeerID(displayName: "livePeer"))
        return autoresponder
    }

    struct MPCFSessionDisplay_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    PreviewBackground {
                        VStack(alignment: .leading) {
                            MPCFSessionDisplay(responder: fakeResponder())
                        }
                    }
                    .environment(\.colorScheme, colorScheme)
                    .previewDisplayName("\(colorScheme)")
                }
            }
        }
    }
#endif
