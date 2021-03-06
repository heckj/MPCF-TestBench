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
    @ObservedObject var session: SessionProxy

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
        session.sessionState == .connected
    }

    private func encryptedSession() -> Bool {
        session.encryptionPreference == .required
    }

    private func connectedPeerStrings() -> [String] {
        return session.connectedPeers.map {
            $0.displayName
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if encryptedSession() {
                    #if os(macOS)
                        Image("lock")
                    #else
                        Image(systemName: "lock")
                    #endif
                } else {
                    #if os(macOS)
                        Image("lock.slash")
                    #else
                        Image(systemName: "lock.slash")
                    #endif
                }
                Text("(ME): \(session.sessionState.rawValue)")
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
                }.animation(.default)
            }
        }
    }
}

#if DEBUG
    private func fakeSessionProxy() -> SessionProxy {
        let session = SessionProxy()
        session.sessionState = .connected
        session.connectedPeers.append(MCPeerID(displayName: "livePeer"))
        return session
    }

    struct MPCFSessionDisplay_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    PreviewBackground {
                        VStack(alignment: .leading) {
                            MPCFSessionDisplay(session: fakeSessionProxy())
                        }
                    }
                    .environment(\.colorScheme, colorScheme)
                    .previewDisplayName("\(colorScheme)")
                }
            }
        }
    }
#endif
