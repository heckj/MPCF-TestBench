//
//  AppDelegate.swift
//  MPCF-TestRunner-ios
//
//  Created by Joseph Heck on 4/26/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import MultipeerConnectivity
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let peerID: MCPeerID
    let proxy: MPCFProxy
    let collector = OTSimpleSpanCollector()
    override init() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        let runner = MPCFTestRunnerModel(spanCollector: collector)
        proxy = MPCFProxy(
            peerID,
            collector: collector,
            encrypt: .required,
            reflectorconfig: false
        )
        proxy.proxyResponder = runner
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(
            name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}
