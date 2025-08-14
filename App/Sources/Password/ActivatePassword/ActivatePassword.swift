//
//  ActivatePassword.swift
//  MagicSecurity
//
//  Created by User on 11.04.25.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct ActivatePassword: Sendable {
    
    @ObservableState
    public struct State: Equatable, Sendable {
        public init() {}
    }
    
    public enum Action {
        case activatePasswordTapped
        case skipPasswordTapped
        case delegate(Delegate)
        
        public enum Delegate {
            case activatePassword
            case skipPassword
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .activatePasswordTapped:
                return .send(.delegate(.activatePassword))
                
            case .skipPasswordTapped:
                return .send(.delegate(.skipPassword))
                
            case .delegate:
                return .none
            }
        }
    }
}
