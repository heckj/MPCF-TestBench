//
//  ContentView.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 4/12/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import SwiftUI

struct ContentView: View {
    @ObservedObject var reflector: MPCFProxy
    var body: some View {
        VStack {
            Text("MPCF Reflector")
            Toggle(isOn: $reflector.active, label: { Text("Active") })
            Text("Found peers: \(reflector.peerList.count)")
            if (reflector.proxyResponder?.currentAdvertSpan) != nil {
                Text("ADVERT SPAN")
            }

            Text("Span collection size: \(reflector.spanCollector.spanBucket.count)")

            List(
                reflector.peerList, id: \.peer,
                rowContent: { ps in
                    MPCFPeerDisplay(peerstatus: ps)
                })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(reflector: MPCFProxy(MCPeerID(displayName: "xpeer")))
    }
}
