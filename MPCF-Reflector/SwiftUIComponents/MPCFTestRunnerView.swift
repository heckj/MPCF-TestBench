//
//  TestRunnerView.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import SwiftUI

struct MPCFTestRunnerView: View {
    @ObservedObject var testrunner: MPCFTestRunnerModel
    func targetSelected() -> Bool {
        testrunner.targetPeer != nil
    }

    func runTest() {
        testrunner.sendTransmissions()
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func exportURL() -> URL {
        let filename = getDocumentsDirectory().appendingPathComponent("output.mpcftestjson")
        do {
            let data = try testrunner.resultData()
            try data.write(to: filename, options: .atomicWrite)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            print(error)
        }
        print(filename)
        return filename
    }

    var body: some View {
        NavigationView {
            VStack {
                MPCFSessionDisplay(session: testrunner.sessionProxy)
                if self.targetSelected() {
                    Divider()
                    Button(action: runTest) {
                        Text("RUN")
                    }
                    .padding()
                }
                NavigationLink(
                    destination: ResultExportView(fileToExport: self.exportURL()),
                    label: {
                        Text("export data")
                            .padding()
                    }
                )
                Divider()
                MPCFTestStatus(testRunnerModel: testrunner)
            }
        }
    }
}

#if DEBUG
    private func fakeTestRunner() -> MPCFTestRunnerModel {
        let me = MPCFTestRunnerModel(
            peer: MCPeerID(displayName: "livePeer"),
            OTSimpleSpanCollector()
        )
        return me
    }

    struct TestRunnerView_Previews: PreviewProvider {
        static var previews: some View {
            MPCFTestRunnerView(testrunner: fakeTestRunner())
        }
    }
#endif
