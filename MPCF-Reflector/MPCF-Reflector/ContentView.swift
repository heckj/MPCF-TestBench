//
//  ContentView.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 4/12/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @ObservedObject var reflector: MPCFReflectorProxy
    var body: some View {
        VStack {
            Text("MPCF Reflector")
            Toggle(isOn: $reflector.active, label: { Text("Active") })
            Text("Found peers: \(reflector.knownPeerDictionary.count)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(reflector: MPCFReflectorProxy(MCPeerID(displayName: "xpeer")))
    }
}
