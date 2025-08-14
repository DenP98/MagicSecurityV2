//
//  OnboardingView.swift
//  MagicSecurity
//
//  Created by User on 10.05.25.
//


import ComposableArchitecture
import SwiftUI

public struct OnboardingView: View {
    @Perception.Bindable var store: StoreOf<Onboarding>
    
    public init(store: StoreOf<Onboarding>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ZStack {
                Color
                    .designSystem(.background)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    Image(store.currentStep.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .animation(.default, value: store.currentStep)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text(store.currentStep.title)
                            .fontSystem(iPhoneSize: 28, iPadSize: 48, weight: .bold)
                            .foregroundColor(.designSystem(.textSecondary))
                        
                        Text(store.currentStep.description)
                            .fontSystem(iPhoneSize: 17, iPadSize: 20)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.designSystem(.textSecondary))
                            .padding(.horizontal)
                    }
                    .animation(.default, value: store.currentStep)
                    
                    Spacer(minLength: 15)
                    
                    HStack(spacing: 8) {
                        ForEach(store.allSteps, id: \.self) { step in
                            Circle()
                                .fill(store.currentStep == step ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Spacer(minLength: 15)
                    
                    Group {
                        if store.currentStep == .stepMobileSecurity {
                            RoundedButton(buttonText: "continue".localized) {
                                store.send(.continueButtonTapped)
                            }
                            
                            Text("by_proceeding_you_accept_markdown".attributedString)
                                .environment(\.openURL, OpenURLAction { url in
                                    store.send(.linkTapped(url))
                                    return .handled
                                })
                                .foregroundColor(.designSystem(.textDescription))
                                .fontSystem(iPhoneSize: 13, iPadSize: 16)
                                .multilineTextAlignment(.center)
                                .frame(height: 40)
                        } else {
                            
                            RoundedButton(buttonText: "continue".localized) {
                                store.send(.continueButtonTapped)
                            }
                            .padding(.bottom, 48)
                        }
                    }
                    .animation(.default, value: store.currentStep)
                }
                .frame(maxWidth: 450)
            }
        }
        .sheet(
            item: $store.scope(state: \.safari,
                               action: \.safari)
        ) { store in
            SafariView(store: store)
        }
    }
}

#Preview {
    OnboardingView(
        store: Store(
            initialState: Onboarding.State()
        ) {
            Onboarding()
        }
    )
}
