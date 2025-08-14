//
//  SetEnterPasswordView.swift
//  MagicSecurity
//
//  Created by User on 11.04.25.
//

import SwiftUI
import ComposableArchitecture

public struct SetEnterPasswordView: View {
    let store: StoreOf<SetEnterPassword>
    
    public init(store: StoreOf<SetEnterPassword>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ZStack {
                    Color
                        .designSystem(.labelBackground)
                        .ignoresSafeArea()
                    
                    VStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.designSystem(.buttonBackground))
                            .frame(height: 60)
                            .overlay(
                                Text(store.currentPassword)
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(.designSystem(.textSecondary))
                            )
                        
                        if let errorMessage = store.errorMessage, !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.designSystem(.attentionPrimary))
                                .font(.caption)
                                .padding(.vertical, 15)
                        } else {
                            Spacer()
                                .frame(height: 40)
                        }
                        
                        Spacer()
                        
                        keypadView
                        
                        Spacer()
                        
                        VStack(spacing: 16) {
                            switch store.currentScreen {
                            case .enter:
                                EmptyView()
                                
                            case .setNew, .confirmNew:
                                RoundedButton(buttonText: "Continue".localized) {
                                    store.send(.continueTapped)
                                }
                                
                                Button {
                                    store.send(.skipPasswordTapped)
                                } label: {
                                    Text("skip".uppercased().localized)
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(.designSystem(.primary))
                                }
                            }
                        }
                    }
                    .navigationTitle(store.currentScreenTitle)
                    .navigationBarTitleDisplayMode(.inline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 40)
                    .frame(maxWidth: 450)
                }
            }
        }
    }
    
    @ViewBuilder
    private var keypadView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
            ForEach(1...9, id: \.self) { number in
                Button {
                    store.send(.numberTapped(number))
                } label: {
                    Text("\(number)")
                        .font(.system(size: 37))
                        .frame(width: 80, height: 80)
                        .background(.designSystem(.buttonBackground))
                        .foregroundColor(.designSystem(.textSecondary))
                        .clipShape(Circle())
                }
            }
            
            Spacer()
                .frame(width: 80, height: 80)
            
            Button {
                store.send(.numberTapped(0))
            } label: {
                Text("0")
                    .font(.system(size: 37))
                    .frame(width: 80, height: 80)
                    .background(.designSystem(.buttonBackground))
                    .foregroundColor(.designSystem(.textSecondary))
                    .clipShape(Circle())
            }
            
            Button {
                store.send(.deleteTapped)
            } label: {
                Image("SetEnterPassword/delete")
                    .frame(width: 80, height: 80)
                    .background(.designSystem(.buttonBackground))
                    .foregroundColor(.designSystem(.textSecondary))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    SetEnterPasswordView(
        store: Store(
            initialState: SetEnterPassword.State()
        ) {
            SetEnterPassword()
        }
    )
}
