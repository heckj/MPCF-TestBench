//
//  AppDelegate.swift
//  MPCF-Reflector-mac
//
//  Created by Joseph Heck on 4/18/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Cocoa
import SwiftUI
import MultipeerConnectivity

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    let peerID = MCPeerID(displayName: Host().name ?? "some mac")
    var reflector: MPCFReflectorProxy?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        reflector = MPCFReflectorProxy(peerID)
        let contentView = ContentView()

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

