//
//  MagicSecurityApp.swift
//  MagicSecurity
//
//  Created by User on 10.05.25.
//

import SwiftUI

@main
struct MagicSecurityApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        UIConfig.setupUI()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: self.appDelegate.store)
        }
        .onChange(of: self.scenePhase) { newPhase in
            self.appDelegate.store.send(.didChangeScenePhase(newPhase))
        }
    }
}
