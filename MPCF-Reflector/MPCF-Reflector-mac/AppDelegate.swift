//
//  AppDelegate.swift
//  MPCF-Reflector-mac
//
//  Created by Joseph Heck on 4/18/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Cocoa
import MultipeerConnectivity
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // @IBOutlet var window: NSWindow! <- storyboard setup mechanism
    // SwiftUI template uses: var window: NSWindow!
    var window: NSWindow?
    let peerID = MCPeerID(displayName: Host.current().name ?? "some mac")
    var reflector: MPCFProxy?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        reflector = MPCFProxy(peerID)
        guard let reflector = reflector else {
            fatalError()
        }
        let contentView = ContentView(proxy: reflector)

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        guard let window = window else {
            return
        }
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
