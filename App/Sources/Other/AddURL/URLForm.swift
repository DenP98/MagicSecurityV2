//
//  URLForm.swift
//  MagicSecurity
//
//  Created by User on 26.04.25.
//


import ComposableArchitecture
import Foundation

@Reducer
public struct URLForm: Sendable {
    public enum EditMode: Equatable {
        case add
        case edit(item: URLItem)
    }
    
    @ObservableState
    public struct State: Equatable {
        let mode: EditMode
        var url: String
        var isURLValid: Bool {
            let pattern = #"""
            ^https?:\/\/(?:[A-Za-z0-9-]+\.)+[A-Za-z]{2,}(?::\d+)?(?:\/\S*)?$
            """#
            return url.range(
                of: pattern,
                options: [.regularExpression]
            ) != nil
        }
        
        init(mode: EditMode, addButtonDisabled: Bool = false) {
            self.mode = mode
            switch mode {
            case let .edit(item: item):
                self.url = item.value.absoluteString
            default:
                self.url = "https://"
            }
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case addTapped
        case cancelTapped
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case urlAdded(URLItem)
            case urlUpdated(URLItem)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addTapped:
                guard state.isURLValid, let url = URL(string: state.url) else { return .none }
                
                switch state.mode {
                case .add:
                    return .merge(
                        .send(.delegate(.urlAdded(URLItem(value: url)))),
                        .run { _ in await self.dismiss() }
                    )
                case .edit(let item):
                    return .merge(
                        .send(.delegate(.urlUpdated(URLItem(id: item.id, value: url)))),
                        .run { _ in await self.dismiss() }
                    )
                }
                
            case .cancelTapped:
                return .run { _ in await self.dismiss() }
                
            case .delegate, .binding:
                return .none
            }
        }
    }
}
