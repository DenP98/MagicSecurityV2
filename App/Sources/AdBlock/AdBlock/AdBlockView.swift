//
//  AdBlockView.swift
//  MagicSecurity
//
//  Created by User on 14.04.25.
//

import ComposableArchitecture
import SwiftUI

public struct AdBlockView: View {
    @Perception.Bindable var store: StoreOf<AdBlock>
    
    public init(store: StoreOf<AdBlock>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ZStack {
                Color
                    .designSystem(.background)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer(minLength: 40)
                    
                    HStack {
                        Spacer(minLength: 60)
                        Image(store.protectionEnabled ? "AdBlock/protection_enabled" : "AdBlock/protection_disabled")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 400)
                        Spacer(minLength: 60)
                    }

                    HStack {
                        Image(store.protectionEnabled ? "AdBlock/green_shield" : "AdBlock/red_warning")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        Text(store.protectionEnabled ? "protection_is_on".localized :
                                "protection_is_off".localized)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(store.protectionEnabled ? .designSystem(.greenPrimary) :
                                .designSystem(.attentionPrimary))
                    }
                    .padding(.vertical, 3)
                    .padding(.horizontal, 10)
                    .background(store.protectionEnabled ? .designSystem(.greenSecondary) :
                            .designSystem(.attentionSecondary))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Spacer(minLength: 59)
                    
                    PowerButton(protectionEnabled: store.protectionEnabled) {
                        store.send(.toggleProtection)
                    }
                    
                    Spacer(minLength: 10)
                    
                    CustomizationBlockView {
                        store.send(.customizationTapped)
                    }
                    .frame(maxWidth: 450)
                    
                    Spacer(minLength: 10)
                        .frame(maxHeight: 50)
                }
            }
            .navigationTitle("adblock".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { store.send(.helpTapped) }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(.blue)
                            .font(.system(size: 17))
                            .padding(.all, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.white)
                            )
                    }
                }
            }
            .sheet(
                item: $store.scope(state: \.destination?.tutorial,
                                   action: \.destination.tutorial)
            ) { store in
                NavigationStack {
                    TutorialView(store: store)
                        .presentationDetents([.height(500)])
                }
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.filters,
                                   action: \.destination.filters)
            ) { store in
                FiltersView(store: store)
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AdBlockView(
            store: Store(
                initialState: AdBlock.State()
            ) {
                AdBlock()
            }
        )
    }
}
