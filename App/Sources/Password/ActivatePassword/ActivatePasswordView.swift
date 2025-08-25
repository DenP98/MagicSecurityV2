//
//  ActivatePasswordView.swift
//  MagicSecurity
//
//  Created by User on 11.04.25.
//

import SwiftUI
import ComposableArchitecture

public struct ActivatePasswordView: View {
    let store: StoreOf<ActivatePassword>
    
    public init(store: StoreOf<ActivatePassword>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                
                Image("ActivatePassword/icon")
                Text("activate_password".localized)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.designSystem(.textSecondary))
                
                Spacer()
                
                RoundedButton(buttonText: "continue".localized) {
                    store.send(.activatePasswordTapped)
                }
                .padding(.bottom, 15)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("skip".localized.uppercased()) {
                        store.send(.skipPasswordTapped)
                    }
                }
            }
            .background(.designSystem(.labelBackground))
        }
    }
}

#Preview {
    ActivatePasswordView(
        store: Store(
            initialState: ActivatePassword.State()
        ) {
            ActivatePassword()
        }
    )
}
