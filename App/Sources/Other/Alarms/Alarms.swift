//
//  Alarms.swift
//  MagicSecurity
//
//  Created by User on 25.04.25.
//

import Foundation
import ComposableArchitecture

public struct Alarms: Reducer {
    @ObservableState
    public struct State: Equatable {
        @Shared private(set) var monitorConfig: SecurityMonitorConfig
        
        public init(monitorConfig: Shared<SecurityMonitorConfig> = .init(value: .init())) {
            self._monitorConfig = monitorConfig
        }
    }
    
    public enum Action {
        case movementChanged(Bool)
        case powerChanged(Bool)
        case headphonesChanged(Bool)
        
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case monitorConfigUpdated(SecurityMonitorConfig)
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .movementChanged(value):
                var config = state.monitorConfig
                config.movement = value
                return .send(.delegate(.monitorConfigUpdated(config)))
                
            case let .powerChanged(value):
                var config = state.monitorConfig
                config.power = value
                return .send(.delegate(.monitorConfigUpdated(config)))
                
            case let .headphonesChanged(value):
                var config = state.monitorConfig
                config.headphones = value
                return .send(.delegate(.monitorConfigUpdated(config)))
                
            case .delegate:
                return .none
            }
        }
    }
}
