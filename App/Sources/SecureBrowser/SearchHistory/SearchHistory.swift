//
//  SearchHistory.swift
//  MagicSecurity
//
//  Created by User on 5.05.25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
public struct SearchHistory: Sendable {
    @ObservableState
    public struct State: Equatable {
        @Shared private(set) var history: [PageItem]
        var clearingProgress: Double? = nil
        
        @Presents public var destination: Destination.State?
        
        public init(history: Shared<[PageItem]> = .init(value: []), isClearing: Bool = false) {
            self._history = history
            self.clearingProgress = isClearing ? 0.0 : nil
        }
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case paywall(Paywall)
    }
    
    public enum Action {
        case onAppear
        case clearHistoryTapped
        case runClearing
        case updateProgress(CGFloat)
        case removeButtonTapped(PageItem)
        case homeButtonTapped
        case clearHistoryCompleted
        
        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case removeHistoryItem(PageItem)
            case clearHistoryRequested
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.continuousClock) var clock
    @Dependency(\.userDefaults) var userDefaults
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.clearingProgress != nil {
                    return .send(.runClearing)
                }
                return .none
            case .clearHistoryTapped:
                return .send(.runClearing)
                
            case .runClearing:
                state.clearingProgress = 0.0
                
                return .merge(
                    .send(.delegate(.clearHistoryRequested)),
                    .run { send in
                        var progress = 0.0
                        
                        for await _ in clock.timer(interval: .milliseconds(25)) {
                            progress += 1.0
                            
                            if progress <= 100 {
                                await send(.updateProgress(progress))
                            } else {
                                await send(.clearHistoryCompleted)
                                return
                            }
                        }
                    }
                )
                
            case .updateProgress(let progress):
                state.clearingProgress = progress
                return .none
                
            case .removeButtonTapped(let item):
                return .send(.delegate(.removeHistoryItem(item)))
                
            case .homeButtonTapped:
                return .run { [dismiss] _ in await dismiss() }
                
            case .clearHistoryCompleted:
                if !userDefaults.hasActiveSubscription {
                    state.destination = .paywall(Paywall.State())
                }
                return .none
                
            case .delegate, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
