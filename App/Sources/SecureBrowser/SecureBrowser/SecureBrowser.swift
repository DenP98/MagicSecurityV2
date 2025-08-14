//
//  SecureBrowser.swift
//  MagicSecurity
//
//  Created by User on 5.05.25.
//

import SwiftUI
import ComposableArchitecture
import WebKit

@Reducer
public struct SecureBrowser: Sendable {
    @ObservableState
    public struct State: Equatable {
        var urlString: String = ""
        var canGoBack: Bool = false
        var canGoForward: Bool = false
        var isLoading: Bool = false
        var webViewError: String? = nil
        var displayedWebViewPage: PageItem?
        var upcomingWebViewAction: WebView.UpcomingAction?
        @Shared(.fileStorage(.pageItemsURL)) var searchHistory: [PageItem] = []
        
        @Presents public var destination: Destination.State?
        
        public init() {}
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case searchHistory(SearchHistory)
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case searchSubmitted
        case goBack
        case goForward
        case refreshTapped
        case cancelTapped
        case showHistoryTapped
        case clearHistoryTapped
        case addToHistory(page: PageItem)
        case destination(PresentationAction<Destination.Action>)
    }
    
    private static let urlPattern = #"^((?:https?:\/\/)?(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*))$"#
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.displayedWebViewPage):
                if let page = state.displayedWebViewPage {
                    state.urlString = page.value.absoluteString
                    if !page.value.absoluteString.isEmpty && page.value.absoluteString != "about:blank" {
                        return .send(.addToHistory(page: page))
                    }
                }
                state.upcomingWebViewAction = nil
                return .none

            case .binding:
                return .none

            case .searchSubmitted:
                let input = state.urlString.trimmingCharacters(in: .whitespacesAndNewlines)
                
                state.isLoading = true
                state.webViewError = nil
                state.upcomingWebViewAction = nil
                
                if let regex = try? NSRegularExpression(pattern: Self.urlPattern, options: []),
                   regex.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.count)) != nil {
                    
                    var urlString = input
                    if !input.lowercased().hasPrefix("http://") && !input.lowercased().hasPrefix("https://") {
                        urlString = "https://" + input
                    }
                    
                    if let url = URL(string: urlString) {
                        state.displayedWebViewPage = PageItem(title: nil, value: url)
                        return .none
                    }
                }
                
                let searchQuery = input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let searchURL = URL(string: "https://www.google.com/search?q=\(searchQuery)")
                state.displayedWebViewPage = if let searchURL {
                    PageItem(title: searchQuery, value: searchURL)
                } else {
                    nil
                }
                return .none
                
            case .goBack:
                state.upcomingWebViewAction = .goBack
                return .none
                
            case .goForward:
                state.upcomingWebViewAction = .goForward
                return .none
                
            case .refreshTapped:
                state.upcomingWebViewAction = .refresh
                return .none
                
            case .cancelTapped:
                state.upcomingWebViewAction = .stopLoading
                return .none
                
            case .showHistoryTapped:
                state.destination = .searchHistory(SearchHistory.State(history: state.$searchHistory))
                return .none
                
            case .clearHistoryTapped:
                state.destination = .searchHistory(SearchHistory.State(isClearing: true))
                return .none
                
            case let .addToHistory(page: page):
                state.$searchHistory.withLock { history in
                    if let last = history.last, last.value == page.value {
                        history[history.endIndex - 1] = PageItem(id: last.id, title: page.title, value: page.value)
                    } else {
                        history += [page]
                    }
                }
                return .none
                
            case .destination(.presented(.searchHistory(.delegate(.clearHistoryRequested)))):
                state.$searchHistory.withLock { $0 = [] }
                state.displayedWebViewPage = nil
                state.urlString = ""
                return .none
                
            case .destination(.presented(.searchHistory(.delegate(.removeHistoryItem(let item))))):
                state.$searchHistory.withLock { history in
                    history.removeAll { $0.id == item.id }
                }
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
