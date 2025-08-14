//
//  SettingsView.swift
//  MagicSecurity
//
//  Created by User on 30.04.25.
//

import SwiftUI
import ComposableArchitecture

public struct SettingsView: View {
    @Perception.Bindable var store: StoreOf<Settings>
    
    public init(store: StoreOf<Settings>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ZStack {
                Color
                    .designSystem(.background)
                    .ignoresSafeArea()
                
                List {
                    HStack {
                        Spacer(minLength: 80)
                        Image("settings")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 250)
                        Spacer(minLength: 80)
                    }
                    .padding([.top, .bottom], 20)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    if !store.isPremium {
                        PremiumButton(isCompact: true) {
                            store.send(.premiumTapped)
                        }
                    }
                    
                    MenuRowView(title: "rate_us".localized,
                                image: Image("rate_us"),
                                isCompact: true,
                                action: {
                        store.send(.rateUsTapped)
                    })
                    
                    MenuRowView(title: "share".localized,
                                image: Image("share"),
                                isCompact: true,
                                action: {
                        store.send(.shareTapped)
                    })
                    
                    if !store.isPremium {
                        MenuRowView(title: "restore_purchase".localized,
                                    image: Image("restore"),
                                    isCompact: true,
                                    action: {
                            store.send(.restoreTapped)
                        })
                    }
                    
                    MenuRowView(title: "privacy_policy".localized,
                                image: Image("privacy_policy"),
                                isCompact: true,
                                action: {
                        store.send(.privacyPolicyTapped)
                    })
                    
                    MenuRowView(title: "terms_of_use".localized,
                                image: Image("terms_of_use"),
                                isCompact: true,
                                action: {
                        store.send(.termsOfUseTapped)
                    })
                }
                .listStyle(.plain)
                .frame(maxWidth: 500)
            }
            .navigationTitle("settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .setupNavigation(store: store)
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

extension View {
    func setupNavigation(store: StoreOf<Settings>) -> some View {
        @Perception.Bindable var store: StoreOf<Settings> = store
        return self
            .fullScreenCover(
                item: $store.scope(state: \.destination?.paywall,
                                   action: \.destination.paywall)
            ) { store in
                PaywallView(store: store)
            }
            .sheet(
                item: $store.scope(state: \.destination?.safari,
                                   action: \.destination.safari)
            ) { store in
                SafariView(store: store)
            }
            .sheet(
                item: $store.scope(state: \.destination?.activity,
                                   action: \.destination.activity)
            ) { store in
                ActivityView(store: store)
            }
    }
}

#Preview {
    SettingsView(
        store: Store(
            initialState: Settings.State()
        ) {
            Settings()
        }
    )
}
