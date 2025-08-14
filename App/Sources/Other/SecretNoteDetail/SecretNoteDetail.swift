//
//  SecretNoteDetail.swift
//  MagicSecurity
//
//  Created by User on 30.04.25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct SecretNoteDetail: Sendable {
    @ObservableState
    public struct State: Equatable {
        var note: Note
        var focus: Field?
        var isKeyboardVisible = false
        
        public init(note: Note, focus: Field? = .title) {
            self.note = note
            self.focus = focus
        }
        
        public enum Field: Hashable {
            case title
            case text
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case keyboardVisibilityChanged(Bool)
        case nextTapped
        case saveButtonTapped
        case deleteButtonTapped
        case delegate(Delegate)
        
        public enum Delegate {
            case noteUpdated(Note)
            case noteDeleted(Note)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case let .keyboardVisibilityChanged(isVisible):
                state.isKeyboardVisible = isVisible
                return .none
                
            case .nextTapped:
                state.focus = .text
                return .none
                
            case .saveButtonTapped:
                state.focus = nil
                guard !state.note.title.isEmpty else { return .none }
                return .send(.delegate(.noteUpdated(state.note)))
                
            case .deleteButtonTapped:
                return .merge(
                    .send(.delegate(.noteDeleted(state.note))),
                    .run { _ in await self.dismiss() }
                )
                
            case .delegate, .binding:
                return .none
            }
        }
    }
}
