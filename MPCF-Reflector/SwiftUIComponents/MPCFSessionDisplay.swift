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
    let session: MCSession
    let sessionState: MPCFSessionState

    /// Exposes the colorscheme in this view so we can make
    /// choices based on it.
    @Environment(\.colorScheme) public var colorSchemeMode
    @EnvironmentObject var fakes: MPCFFakes

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
        return sessionState == .connected
    }

    private func encryptedSession() -> Bool {
        session.encryptionPreference == .required
    }

    private func connectedPeerStrings() -> [String] {
        if fakes.fakeData {
            return fakes.fakePeerNames
        } else {
            return session.connectedPeers.map {
                $0.displayName
            }
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
                Text("Session: \(sessionState.rawValue)")
            }
            HStack {
                Image(systemName: "person.2.square.stack").font(.headline)
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
    private func fakeSession() -> MCSession {
        let me = MCPeerID(displayName: "thisPeer")
        let x = MCSession(peer: me, securityIdentity: nil, encryptionPreference: .required)
        return x
    }

    struct MPCFSessionDisplay_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    PreviewBackground {
                        VStack(alignment: .leading) {
                            MPCFSessionDisplay(session: fakeSession(), sessionState: .connected)
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
