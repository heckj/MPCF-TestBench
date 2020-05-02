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
    let proxy: MPCFProxy
    var body: some View {
        Text("yo")
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
