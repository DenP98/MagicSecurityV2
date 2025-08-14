//
//  Splash.swift
//  MagicSecurity
//
//  Created by User on 10.05.25.
//

import ComposableArchitecture

@Reducer
public struct Splash : Sendable {
    
    @ObservableState
    public struct State: Equatable {
        var progress: Double = 0
        
        public init(progress: Double = 0) {
            self.progress = progress
        }
    }
    
    public enum Action {
        case onAppear
        case updateProgress(Double)
        case delegate(Delegate)
        
        public enum Delegate {
            case finished
        }
    }
    
    @Dependency(\.continuousClock) var clock
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    var progress = 0.0
                    
                    for await _ in clock.timer(interval: .milliseconds(64)) {
                        progress += 2

                        if progress >= 101 {
                            await send(.delegate(.finished))
                            break
                        } else {
                            await send(.updateProgress(progress))
                        }
                    }
                }
                
            case let .updateProgress(newProgress):
                state.progress = newProgress
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
