//
//  Tutorial.swift
//  MagicSecurity
//
//  Created by User on 14.04.25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct Tutorial: Sendable {
    @ObservableState
    public struct State: Equatable {
    }
    
    public enum Action {
        case skipTapped
        case openSettingsTapped
        
        case delegate(Delegate)
        
        public enum Delegate {
            case dismiss
        }
    }
    
    @Dependency(\.applicationClient) var applicationClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .skipTapped:
                return .send(.delegate(.dismiss))
                
            case .openSettingsTapped:
                return .run { _ in
                    guard let url = await URL(string: self.applicationClient.openSettingsURLString()) else {
                        return
                    }
                    _ = await self.applicationClient.open(url, [:])
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
