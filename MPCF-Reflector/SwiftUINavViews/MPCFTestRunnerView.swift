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
                    // NOTE(heckj) - using a method for this ends up being strange -
                    // the resulting method gets called repeatedly as the view is
                    // updated, and since I have it generating the output file to
                    // provide the URL, it's getting invoked repeatedly. I probably
                    // need to refactor this whole thing to stash the URL as local
                    // @State here in the view, and update it when I need it, rather
                    // than letting the view hierarchy trigger the update implicitly.
                    //
                    // That said, the target view is complete crap to use - my attempt
                    // to wrap a file export picker with a UIViewRepresentable ends
                    // up bring pretty sub-par, and useless on macOS to boot.
                    label: {
                        Text("export data")
                            .padding()
                    }
                )
                Divider()
                MPCFTestStatus(testRunnerModel: testrunner)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
