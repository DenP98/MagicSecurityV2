//
//  Settings.swift
//  MagicSecurity
//
//  Created by User on 30.04.25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct Settings: Sendable {
    @Reducer(state: .equatable)
    public enum Destination {
        case paywall(Paywall)
        case safari(Safari)
        case activity(Activity)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents public var destination: Destination.State?
        var isPremium = false
        
        public init(destination: Destination.State? = nil, isPremium: Bool = false) {
            self.destination = destination
            self.isPremium = isPremium
        }
    }
    
    public enum Action {
        case onAppear
        case destination(PresentationAction<Destination.Action>)
        case premiumTapped
        case rateUsTapped
        case shareTapped
        case restoreTapped
        case privacyPolicyTapped
        case termsOfUseTapped
    }
    
    @Dependency(\.storeKitClient) var storeKitClient
    @Dependency(\.userDefaults) var userDefaults
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isPremium = userDefaults.hasActiveSubscription
                return .none
                
            case .premiumTapped:
                state.destination = .paywall(Paywall.State())
                return .none
                
            case .rateUsTapped:
                return .run { _ in
                    await storeKitClient.requestReview()
                }
                
            case .shareTapped:
                let text = "Check out Magic Security!"
                guard let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID") else {
                    assertionFailure("Link is broken")
                    return .none
                }
                state.destination = .activity(Activity.State(text: text, url: url))
                return .none
                
            case .privacyPolicyTapped:
                guard let link = URL(string: "privacy_policy_link".localized) else {
                    assertionFailure("Link is broken")
                    return .none
                }
                state.destination = .safari(Safari.State(url: link))
                return .none
                
            case .termsOfUseTapped:
                guard let link = URL(string: "terms_of_use_link".localized) else {
                    assertionFailure("Link is broken")
                    return .none
                }
                state.destination = .safari(Safari.State(url: link))
                return .none
                
            case .destination(.presented(.paywall(.delegate(.purchaseCompleted)))):
                state.isPremium = userDefaults.hasActiveSubscription
                return .none
                
            case .restoreTapped:
                return .run { _ in
                    do {
                        try await storeKitClient.restore()
                    } catch {
                        
                    }
                }
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
