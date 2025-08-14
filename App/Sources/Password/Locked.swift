//
//  Locked.swift
//  MagicSecurity
//
//  Created by User on 28.05.25.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct Locked<Content: Reducer>: Reducer, Sendable where Content: Sendable, Content.State: Equatable {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case activatePassword(ActivatePassword)
        case setEnterPassword(SetEnterPassword)
    }
    
    @ObservableState
    public struct State: Equatable {
        var content: Content.State
        @Presents public var destination: Destination.State?
        
        public init(content: Content.State) {
            self.content = content
        }
    }
    
    public enum Action {
        case onAppear
        case content(Content.Action)
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(\.userDefaults) var userDefaults
    
    let contentReducer: Content
    
    public init(contentReducer: Content) {
        self.contentReducer = contentReducer
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if userDefaults.passwordHash != nil {
                    state.destination = .setEnterPassword(SetEnterPassword.State(screenType: .enter))
                } else {
                    state.destination = .activatePassword(ActivatePassword.State())
                }
                return .none
                
            case .destination(.presented(.activatePassword(.delegate(.activatePassword)))):
                state.destination = .setEnterPassword(SetEnterPassword.State(screenType: .setNew))
                return .none
                
            case .destination(.presented(.activatePassword(.delegate(.skipPassword)))):
                state.destination = nil
                return .none
                
            case .destination(.presented(.setEnterPassword(.delegate(.passwordVerified)))):
                state.destination = nil
                return .none
                
            case .destination(.presented(.setEnterPassword(.delegate(.passwordSkipped)))):
                state.destination = nil
                return .none
                
            case .content, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        
        Scope(state: \.content, action: \.content) {
            contentReducer
        }
    }
}
