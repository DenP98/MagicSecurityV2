//
//  URLList.swift
//  MagicSecurity
//
//  Created by User on 26.04.25.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct URLList {
    public enum ListType {
        case black
        case white
        
        var titleKey: String {
            self == .black ? "black_list" : "white_list"
        }
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case urlForm(URLForm)
    }
    
    @ObservableState
    public struct State: Equatable {
        var type: ListType
        @Shared private(set) var urls: [URLItem]
        @Presents var destination: Destination.State? = nil
        
        init(
            type: ListType,
            urls: Shared<[URLItem]> = .init(value: [])
        ) {
            self.type = type
            self._urls = urls
        }
    }
    
    public enum Action {
        case urlTapped(URLItem)
        case addURLTapped
        case deleteURL(URLItem)
        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case blackListUpdated([URLItem])
            case whiteListUpdated([URLItem])
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .urlTapped(urlItem):
                state.destination = .urlForm(URLForm.State(mode: .edit(item: urlItem)))
                return .none
                
            case .addURLTapped:
                state.destination = .urlForm(URLForm.State(mode: .add))
                return .none
                
            case let .deleteURL(url):
                let updateURLs = state.urls.filter { $0.id != url.id }
                
                switch state.type {
                case .black:
                    return .send(.delegate(.blackListUpdated(updateURLs)))
                case .white:
                    return .send(.delegate(.whiteListUpdated(updateURLs)))
                }
                
            case let .destination(.presented(.urlForm(.delegate(.urlAdded(url))))):
                switch state.type {
                case .black:
                    return .send(.delegate(.blackListUpdated(state.urls + [url])))
                case .white:
                    return .send(.delegate(.whiteListUpdated(state.urls + [url])))
                }
                
            case let .destination(.presented(.urlForm(.delegate(.urlUpdated(url))))):
                let updateURLs = state.urls.map { item in
                    guard item.id == url.id else { return item }
                    return URLItem(id: item.id, value: url.value)
                }
                switch state.type {
                case .black:
                    return .send(.delegate(.blackListUpdated(updateURLs)))
                case .white:
                    return .send(.delegate(.whiteListUpdated(updateURLs)))
                }
            
            case .destination, .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
