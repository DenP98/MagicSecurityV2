//
//  LockedView.swift
//  MagicSecurity
//
//  Created by User on 28.05.25.
//

import SwiftUI
import ComposableArchitecture

public struct LockedView<ContentReducer: Reducer, Content: View>: View 
where ContentReducer: Sendable, ContentReducer.State: Equatable {
    
    @Perception.Bindable var store: StoreOf<Locked<ContentReducer>>
    let content: (StoreOf<ContentReducer>) -> Content
    
    public init(
        store: StoreOf<Locked<ContentReducer>>,
        @ViewBuilder content: @escaping (StoreOf<ContentReducer>) -> Content
    ) {
        self.store = store
        self.content = content
    }
    
    public var body: some View {
        WithPerceptionTracking {
            content(
                store.scope(state: \.content, action: \.content)
            )
            .sheet(item: $store.scope(state: \.destination?.activatePassword,
                                      action: \.destination.activatePassword),
                   content: { store in
                ActivatePasswordView(store: store)
                    .presentationDetents([.height(400)])
            })
            .fullScreenCover(item: $store.scope(state: \.destination?.setEnterPassword,
                                                action: \.destination.setEnterPassword),
                             content: { store in
                SetEnterPasswordView(store: store)
            })
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}
