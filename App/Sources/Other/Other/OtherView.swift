//
//  OtherView.swift
//  MagicSecurity
//
//  Created by User on 28.04.25.
//

import SwiftUI
import ComposableArchitecture

public struct OtherView: View {
    @Perception.Bindable var store: StoreOf<Other>
    
    public init(store: StoreOf<Other>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ZStack {
                Color
                    .designSystem(.background)
                    .ignoresSafeArea()
                
                List {
                    if !store.isPremium {
                        PremiumButton {
                            store.send(.premiumButtonTapped)
                        }
                    }
                    
                    OtherViewRow(
                        title: "black_list".localized,
                        subtitle: "\(store.blackListItems.count) URL",
                        image: Image("Other/black_list"),
                        action: { store.send(.blackListTapped) }
                    )
                    
                    OtherViewRow(
                        title: "white_list".localized,
                        subtitle: "\(store.whiteListItems.count) URL",
                        image: Image("Other/white_list"),
                        action: { store.send(.whiteListTapped) }
                    )
                    
                    OtherViewRow(
                        title: "secret_notes".localized,
                        subtitle: "\(store.secretNotes.count) notes",
                        image: Image("Other/secret_notes"),
                        action: { store.send(.secretNotesTapped) }
                    )
                    
                    OtherViewRow(
                        title: "alarms".localized,
                        subtitle: "\(store.alarmsCount) active",
                        image: Image("Other/alarms"),
                        action: { store.send(.alarmsTapped) }
                    )
                }
                .listStyle(.plain)
                .frame(maxWidth: 450)
            }
            .navigationTitle("other".localized)
            .navigationBarTitleDisplayMode(.inline)
            .setupDestinations(store: store)
            .setupLockDestination(store: store)
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

fileprivate extension View {
    func setupDestinations(store: StoreOf<Other>) -> some View {
        @Perception.Bindable var store = store
        return self
            .fullScreenCover(
                item: $store.scope(state: \.destination?.paywall,
                                   action: \.destination.paywall)
            ) { store in
                PaywallView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.blackList,
                                   action: \.destination.blackList),
                destination: { store in
                    URLListView(store: store)
                }
            )
            .navigationDestination(
                item: $store.scope(state: \.destination?.whiteList,
                                   action: \.destination.whiteList),
                destination: { store in
                    URLListView(store: store)
                }
            )
            .navigationDestination(
                item: $store.scope(state: \.destination?.secretNotes,
                                   action: \.destination.secretNotes),
                destination: { store in
                    SecretNotesView(store: store)
                }
            )
            .navigationDestination(
                item: $store.scope(state: \.destination?.alarms,
                                   action: \.destination.alarms),
                destination: { store in
                    AlarmsView(store: store)
                }
            )
    }
    
    func setupLockDestination(store: StoreOf<Other>) -> some View {
        @Perception.Bindable var store = store
        return self
            .sheet(item: $store.scope(state: \.destination?.activatePassword,
                                      action: \.destination.activatePassword),
                   content: { store in
                ActivatePasswordView(store: store).presentationDetents([.height(400)])
            })
            .fullScreenCover(item: $store.scope(state: \.destination?.setEnterPassword,
                                                action: \.destination.setEnterPassword),
                             content: { store in
                SetEnterPasswordView(store: store)
            })
    }
}

struct OtherView_Previews: PreviewProvider {
    static var previews: some View {
        OtherView(
            store: Store(initialState: Other.State()) {
                Other()
            }
        )
    }
}
