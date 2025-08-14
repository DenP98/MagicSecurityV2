//
//  MainTabView.swift
//  MagicSecurity
//
//  Created by User on 14.04.25.
//

import ComposableArchitecture
import SwiftUI


public struct MainMenuView: View {
    let store: StoreOf<MainMenu>
    
    public init(store: StoreOf<MainMenu>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            TabView() {
                NavigationView {
                    AdBlockView(store: store.scope(state: \.adBlock, action: \.adBlock))
                }
                .tabItem {
                    Image("MainMenu/adblock_icon")
                    Text("adblock".localized)
                }
                
                NavigationView {
                    LockedView(store: store.scope(state: \.lockedSecureBrowser, action: \.lockedSecureBrowser),
                               content: { store in
                        SecureBrowserView(store: store)
                    })
                }
                .tabItem {
                    Image("MainMenu/secure_browser_icon")
                    Text("browser".localized)
                }
                
                NavigationView {
                    OtherView(store: store.scope(state: \.other, action: \.other))
                }
                    .tabItem {
                        Image("MainMenu/other_icon")
                        Text("other".localized)
                    }
                
                SettingsView(store: store.scope(state: \.settings, action: \.settings))
                .tabItem {
                    Image("MainMenu/settings_icon")
                    Text("settings".localized)
                }
            }
            .environment(\.horizontalSizeClass, .compact)
            .tint(.designSystem(.primary))
        }
    }
}

#Preview {
    MainMenuView(
        store: Store(
            initialState: MainMenu.State()
        ) {
            MainMenu()
        }
    )
    .onAppear {
        UIConfig.setupUI()
    }
}
