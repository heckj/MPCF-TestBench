//
//  MPCFReflectorStatus.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import PreviewBackground
import SwiftUI

struct MPCFReflectorStatus: View {

    @ObservedObject var reflector: MPCFReflectorModel
    var body: some View {
        VStack(alignment: .leading) {

            Text("Transmissions: ").font(.headline)
                + Text("\(reflector.numberOfTransmissionsRecvd)")
            Divider()
            List(reflector.transmissions) {
                xmit in
                HStack {
                    Text(xmit.traceName).font(.caption)
                    Text("\(xmit.sequenceNumber)").font(.caption)
                    Text(String(describing: xmit.transport)).font(.caption)
                }
            }
            Divider()
            HStack {
                ForEach(reflector.errorList, id: \.self) {
                    Text($0).font(.caption)
                }
            }
        }

    }
}

#if DEBUG
    private func fakeReflector() -> MPCFReflectorModel {
        let thispeer = MCPeerID(displayName: "thisPeer")
        let me = MPCFReflectorModel(peer: thispeer, OTSimpleSpanCollector())
        for _ in 1...30 {
            me.transmissions.append(TransmissionIdentifier(traceName: "foo"))
        }
        return me
    }

    struct MPCFReflectorStatus_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    PreviewBackground {
                        VStack(alignment: .leading) {
                            MPCFReflectorStatus(reflector: fakeReflector())
                        }
                    }
                    .environment(\.colorScheme, colorScheme)
                    .previewDisplayName("\(colorScheme)")
                }
            }
        }
    }
#endif
