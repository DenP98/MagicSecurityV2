//
//  AppDelegate.swift
//  MagicSecurity
//
//  Created by User on 13.04.25.
//

import Foundation
import UIKit
import ComposableArchitecture

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    let store = Store(
        initialState: AppReducer.State()
    ) {
        AppReducer()
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            NotificationCenter.default.post(
                name: .quickActionTriggered,
                object: shortcutItem.type
            )
        }
        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        NotificationCenter.default.addObserver(
            forName: .quickActionTriggered,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let actionType = notification.object as? String else { return }
            self?.store.send(.appDelegate(.quickActionTriggered(actionType)))
        }
        
        store.send(.appDelegate(.didFinishLaunching(application)))
        return true
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        NotificationCenter.default.post(
            name: .quickActionTriggered,
            object: shortcutItem.type
        )
        completionHandler(true)
    }
}

extension Notification.Name {
    static let quickActionTriggered = Notification.Name("QuickActionTriggered")
}
