//
//  AppDelegate.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 4/12/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let peerID: MCPeerID
    let reflector: MPCFReflectorProxy
    override init() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        reflector = MPCFReflectorProxy(peerID)
    }

    // MARK: Lifecycle

    func applicationWillEnterForeground(_: UIApplication) {
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_: UIApplication) {
        print("applicationDidBecomeActive")
    }

    func applicationWillResignActive(_: UIApplication) {
        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_: UIApplication) {
        print("applicationDidEnterBackground")
    }

    func applicationWillTerminate(_: UIApplication) {
        print("applicationWillTerminate")
    }

    // MARK: Launching

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(
            name: "Default Configuration", sessionRole: connectingSceneSession.role
        )
    }

    func application(
        _: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>
    ) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: MCSessionDelegate {
    func session(_: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")

        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")

        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        @unknown default:
            fatalError("unsupported MCSessionState result")
        }
    }

    func session(_: MCSession, didReceive _: Data, fromPeer _: MCPeerID) {
        print("received data")
    }

    func session(
        _: MCSession, didReceive _: InputStream, withName _: String,
        fromPeer _: MCPeerID
    ) {
        print("received stream")
    }

    func session(
        _: MCSession, didStartReceivingResourceWithName resourceName: String,
        fromPeer _: MCPeerID, with _: Progress
    ) {
        print("starting receiving resource: \(resourceName)")
    }

    func session(
        _: MCSession, didFinishReceivingResourceWithName resourceName: String,
        fromPeer _: MCPeerID, at _: URL?, withError _: Error?
    ) {
        print("finished receiving resource: \(resourceName)")
    }
}
