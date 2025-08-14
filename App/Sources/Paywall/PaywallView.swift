//
//  PaywallVies.swift
//  MagicSecurity
//
//  Created by User on 12.04.25.
//

import SwiftUI
import ComposableArchitecture


public struct PaywallView: View {
    @Perception.Bindable var store: StoreOf<Paywall>
    
    public init(store: StoreOf<Paywall>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ZStack {
                Color
                    .designSystem(.background)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer(minLength: 20)
                    
                    Text("activate_web_protection".localized.uppercased())
                        .fontSystem(iPhoneSize: 28, iPadSize: 48, weight: .bold)
                        .foregroundStyle(.designSystem(.textPrimary))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 450)
                    
                    Spacer(minLength: 12)
                    
                    Text("enjoy_the_full_experience_of_app".localized)
                        .fontSystem(iPhoneSize: 17, iPadSize: 20)
                        .foregroundStyle(.designSystem(.textPrimary))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 450)
                    
                    Spacer(minLength: 20)
                    
                    Image("activate_web_protection_icon")
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 20)
                        .padding([.leading, .trailing, .bottom], 24)
                        .frame(maxWidth: 600)
                    
                    Spacer(minLength: 4)
                    
                    VStack(spacing: 12) {
                        subscriptionOptionView(
                            title: "free_trial_for_days".localized,
                            price: "\(store.weeklyPrice) / \("week".localized)",
                            isSelected: store.selectedPlan == .weekly
                        ) {
                            store.send(.selectPlan(.weekly))
                        }
                        
                        subscriptionOptionView(
                            title: "annual_access".localized,
                            price: "\(store.yearlyPrice) / \("year".localized)",
                            badge: store.discountSize,
                            isSelected: store.selectedPlan == .yearly
                        ) {
                            store.send(.selectPlan(.yearly))
                        }
                        
                        HStack {
                            Text(store.isFreeTrialEnabled ? "free_trial_enabled".localized : "free_trial_disabled".localized)
                                .fontSystem(iPhoneSize: 17, iPadSize: 22, weight: .bold)
                                .foregroundStyle(.designSystem(.textSecondary))
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { store.isFreeTrialEnabled },
                                set: { _ in store.send(.toggleFreeTrialSwitched) }
                            ))
                            .tint(.designSystem(.primary))
                            .padding(.vertical, 3)
                            .disabled(store.isLoading)
                        }
                        .roundedSelectable(isSelected: false)
                    }
                    .frame(maxWidth: 450)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 15)
                    
                    HStack {
                        Image("checkmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text(store.isFreeTrialEnabled ? "no_payment_now".localized : "cancel_anytime".localized)
                            .fontSystem(iPhoneSize: 13, iPadSize: 16, weight: .bold)
                            .foregroundStyle(.designSystem(.greenPrimary))
                    }
                    .padding(.vertical, 3)
                    .padding(.horizontal, 10)
                    .background(.designSystem(.greenSecondary))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Spacer(minLength: 15)
                    
                    RoundedButton(buttonText: store.isLoading ? "loading".localized : "continue".localized) {
                        store.send(.continueButtonTapped)
                    }
                    .frame(maxWidth: 490)
                    
                    Spacer(minLength: 14)
                    
                    HStack(spacing: 24) {
                        Button("privacy_policy".localized) { store.send(.privacyPolicyTapped) }
                            .disabled(store.isLoading)
                        Button("restore".localized) { store.send(.restoreTapped) }
                            .disabled(store.isLoading)
                        Button("skip".localized) { store.send(.skipTapped) }
                            .disabled(store.isLoading)
                        Button("terms_of_use".localized) { store.send(.termsOfUseTapped) }
                            .disabled(store.isLoading)
                    }
                    .fontSystem(iPhoneSize: 13, iPadSize: 16)
                    .foregroundStyle(.designSystem(.textDescription))
                    
                    Spacer(minLength: 18)
                }
            }
            .onAppear { store.send(.onAppear) }
            .sheet(
                item: $store.scope(state: \.safari,
                                   action: \.safari)
            ) { store in
                SafariView(store: store)
            }
        }
    }
    
    private func subscriptionOptionView(
        title: String,
        price: String,
        badge: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .fontSystem(iPhoneSize: 17, iPadSize: 22, weight: .bold)
                        .foregroundStyle(.designSystem(.textSecondary))
                    Text(price)
                        .fontSystem(iPhoneSize: 15, iPadSize: 20)
                        .foregroundStyle(.designSystem(.textDescription))
                }
                Spacer()
                if let badge {
                    Text(badge)
                        .fontSystem(iPhoneSize: 11, iPadSize: 14, weight: .bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(isSelected ? .designSystem(.attentionPrimary) : .designSystem(.attentionSecondary))
                        .foregroundStyle(isSelected ? .designSystem(.buttonText) : .designSystem(.attentionPrimary))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .roundedSelectable(isSelected: isSelected)
        .disabled(store.isLoading)
    }
}

#Preview {
    PaywallView(
        store: Store(
            initialState: Paywall.State()
        ) {
            Paywall()
        }
    )
}
