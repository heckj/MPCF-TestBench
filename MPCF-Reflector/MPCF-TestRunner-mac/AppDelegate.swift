//
//  AppDelegate.swift
//  MPCF-TestRunner-mac
//
//  Created by Joseph Heck on 4/26/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Cocoa
import MultipeerConnectivity

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let peerID: MCPeerID
    let proxy: MPCFProxy
    let runner: MPCFTestRunnerModel
    let collector = OTSimpleSpanCollector()
    override init() {
        peerID = MCPeerID(displayName: Host.current().name ?? "unknown")
        runner = MPCFTestRunnerModel(peer: peerID, collector)
        proxy = MPCFProxy(
            peerID,
            collector: collector,
            encrypt: .required,
            reflectorconfig: false
        )
        proxy.proxyResponder = runner
    }

    func applicationDidFinishLaunching(_: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }
}
