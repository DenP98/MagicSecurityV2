//
//  AppView.swift
//  MagicSecurity
//
//  Created by User on 7.04.25.
//

import SwiftUI
import ComposableArchitecture
public struct AppView: View {
    let store: StoreOf<AppReducer>
    
    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.destination {
                case .some(.splash):
                    if let store = store.scope(state: \.destination?.splash, action: \.destination.splash) {
                        SplashView(store: store)
                    }
                    
                case .some(.onboarding):
                    if let store = store.scope(state: \.destination?.onboarding, action: \.destination.onboarding) {
                        OnboardingView(store: store)
                    }
                    
                case .some(.paywall):
                    if let store = store.scope(state: \.destination?.paywall, action: \.destination.paywall) {
                        PaywallView(store: store)
                    }
                    
                case .some(.mainMenu):
                    if let store = store.scope(state: \.destination?.mainMenu, action: \.destination.mainMenu) {
                        MainMenuView(store: store)
                    }
                    
                case .none:
                    Text("Somethiung went wrong")
                }
            }
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppReducer.State()) {
            AppReducer()
        }
    )
}
