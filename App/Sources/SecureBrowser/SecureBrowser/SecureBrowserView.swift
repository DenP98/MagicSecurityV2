//
//  SecureBrowserView.swift
//  MagicSecurity
//
//  Created by User on 5.05.25.
//

import SwiftUI
import ComposableArchitecture

public struct SecureBrowserView: View {
    @Perception.Bindable var store: StoreOf<SecureBrowser>
    
    public init(store: StoreOf<SecureBrowser>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Image("SecureBrowser/google_logo")
                            
                            TextField("search".localized, text: $store.urlString)
                                .textFieldStyle(.plain)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .onSubmit { store.send(.searchSubmitted) }
                            
                            if store.displayedWebViewPage != nil {
                                if store.isLoading {
                                    Button(action: { store.send(.cancelTapped) }) {
                                        Image("SecureBrowser/cancel")
                                    }
                                } else {
                                    Button(action: { store.send(.refreshTapped) }) {
                                        Image("SecureBrowser/refresh")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 36)
                        .frame(height: 74)
                        .background {
                            Capsule()
                                .fill(.designSystem(.background))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 15)
                        }
                        .frame(maxWidth: 450)
                        
                        Spacer()
                    }
                    .background(.designSystem(.buttonText))
                    
                    ZStack {
                        if let url = store.displayedWebViewPage?.value {
                            WebView(
                                loadURL: url,
                                isLoading: $store.isLoading,
                                webViewError: $store.webViewError,
                                displayPage: $store.displayedWebViewPage,
                                canGoBack: $store.canGoBack,
                                canGoForward: $store.canGoForward,
                                upcomingAction: $store.upcomingWebViewAction
                            )
                        } else {
                            VStack {
                                Spacer()
                                Image("SecureBrowser/placeholder")
                                Spacer()
                            }
                        }
                        
                        if let error = store.webViewError {
                            ErrorDisplayView(errorMessage: error)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(.designSystem(.background))
                .navigationTitle("secure_browser".localized)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button(action: { store.send(.goBack) }) {
                            Image(systemName: "chevron.left")
                        }
                        .disabled(!store.canGoBack)
                        
                        Button(action: { store.send(.goForward) }) {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(!store.canGoForward)
                    }
                    
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Menu {
                            Button(action: { store.send(.showHistoryTapped) }) {
                                Text("search_history".localized)
                                Image("SecureBrowser/search_history")
                            }
                            Button(action: { store.send(.clearHistoryTapped) }) {
                                Text("clear_search_history".localized)
                                Image("SecureBrowser/clear_search_history")
                            }
                        } label: {
                            Image("SecureBrowser/menu")
                                .padding(.trailing, 12)
                        }
                    }
                }
                .navigationDestination(
                    item: $store.scope(state: \.destination?.searchHistory,
                                       action: \.destination.searchHistory)
                ) { store in
                    SearchHistoryView(store: store)
                }
            }
        }
    }
}

#Preview {
    SecureBrowserView(
        store: Store(
            initialState: SecureBrowser.State()
        ) {
            SecureBrowser()
        }
    )
}
