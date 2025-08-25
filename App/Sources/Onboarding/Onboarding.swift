//
//  OnboardingReducer.swift
//  MagicSecurity
//
//  Created by User on 11.04.25.
//

import Foundation
import ComposableArchitecture


@Reducer
public struct Onboarding {
    @ObservableState
    public struct State: Equatable {
        public var currentStep: Step
        public var allSteps: [Step]
        @Presents public var safari: Safari.State?
        
        public init(currentStep: Step = .allCases.first!,
                    safari: Safari.State? = nil) {
            self.currentStep = currentStep
            self.allSteps = Step.allCases
            self.safari = safari
        }
        
        public enum Step: Int, CaseIterable, Comparable, Equatable, Identifiable {
            case stepMobileSecurity
            case stepWebAnonymity
            case stepDataProtection
        }
    }
    
    public enum Action {
        case continueButtonTapped
        case linkTapped(URL)
        case safari(PresentationAction<Safari.Action>)
        
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case finished
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .continueButtonTapped:
                guard !state.currentStep.isLast else {
                    return .send(.delegate(.finished))
                }
                state.currentStep.next()
                return .none
                
            case let .linkTapped(url):
                state.safari = Safari.State(url: url)
                return .none
                
            case .delegate, .safari:
                return .none
            }
        }
        .ifLet(\.$safari, action: \.safari) {
            Safari()
        }
    }
}

extension Onboarding.State.Step {
    mutating func next() {
        self = Self(rawValue: self.rawValue + 1) ?? Self.allCases.last!
    }
    
    var isLast: Bool {
        self == Self.allCases.last
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    public var id: Int { self.rawValue }
    
    public var title: String {
        switch self {
        case .stepMobileSecurity: String(localized: "Online Security")
        case .stepWebAnonymity: String(localized: "Web Anonymity")
        case .stepDataProtection: String(localized: "Data Protection")
        }
    }
    
    public var description: String {
        switch self {
        case .stepMobileSecurity: String(localized: "Block ads and trackers for a smoother and safer online experience")
        case .stepWebAnonymity: String(localized: "Browse privately and keep your online activity hidden from others")
        case .stepDataProtection: String(localized: "Lock your secret notes and secure browser with a password only you can access")
        }
    }
    
    public var imageName: String {
        switch self {
        case .stepMobileSecurity: "mobile_security_icon"
        case .stepWebAnonymity: "web_anonymity_icon"
        case .stepDataProtection: "data_protection_icon"
        }
    }
}
