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
            }.animation(.default)
            Divider()
            Text("Errors: ").font(.headline)
                + Text("\(reflector.errorList.count)")
            List(reflector.errorList, id: \.self) {
                Text($0).font(.caption).padding(
                    EdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
                ).overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            Color.init(
                                Color.RGBColorSpace.sRGB,
                                red: 1.0,
                                green: 0.1,
                                blue: 0.1,
                                opacity: 0.3)
                        )
                )
            }.animation(.default)
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
        me.errorList.append("oops - something bad")
        me.errorList.append("some really, really, really long error message")
        me.errorList.append("darnit, again")
        me.errorList.append("NO! Really!?")
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
