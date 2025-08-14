//
//  SearchHistoryView.swift
//  MagicSecurity
//
//  Created by User on 5.05.25.
//

import SwiftUI
import ComposableArchitecture

public struct SearchHistoryView: View {
    @Perception.Bindable var store: StoreOf<SearchHistory>
    
    public init(store: StoreOf<SearchHistory>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                if let clearingProgress = store.clearingProgress {
                    ClearingAnimationView(progress: clearingProgress) {
                        store.send(.homeButtonTapped)
                    }
                    .navigationBarBackButtonHidden(true)
                    .fullScreenCover(
                        item: $store.scope(state: \.destination?.paywall,
                                           action: \.destination.paywall)
                    ) { store in
                        PaywallView(store: store)
                    }
                    .onAppear { store.send(.onAppear) }
                } else {
                    Group {
                        if store.history.isEmpty {
                            VStack {
                                Image("SearchHistory/empty_history")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 350)
                                    .padding(.horizontal, 50)
                                Text("empty_search_history".localized)
                                    .fontSystem(iPhoneSize: 17, iPadSize: 20)
                                    .foregroundStyle(.designSystem(.textDescription))
                                    .padding(.top, 24)
                            }
                        } else {
                            List(store.history) { item in
                                HStack(spacing: 12) {
                                    AsyncImage(url: faviconURL(for: item)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        Image(systemName: "globe")
                                            .resizable()
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 28, height: 28)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        if let title = item.title, !title.isEmpty {
                                            Text(title)
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.designSystem(.textSecondary))
                                                .lineLimit(1)
                                        } else {
                                            Text(item.value.host ?? item.value.absoluteString)
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.designSystem(.textSecondary))
                                                .lineLimit(1)
                                        }
                                        
                                        Text(item.value.absoluteString)
                                            .font(.system(size: 15, weight: .regular))
                                            .foregroundColor(.designSystem(.textDescription))
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        store.send(.removeButtonTapped(item))
                                    } label: {
                                        Image("SearchHistory/remove")
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .frame(maxWidth: 450)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Clear", role: .destructive) {
                                        store.send(.clearHistoryTapped)
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle("search_history".localized)
                    .navigationBarTitleDisplayMode(.inline)
                    .background(.designSystem(.background))
                    .onAppear { store.send(.onAppear) }
                }
            }
        }
    }
    
    func faviconURL(for item: PageItem) -> URL? {
        guard let host = item.value.host else { return nil }
        return URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=32")
    }
}

#Preview {
    SearchHistoryView(
        store: Store(
            initialState: SearchHistory.State(
                history: .init(value: [
                                        PageItem(title: "VKontakteVKontakteVKontakteVKontakte", value: URL(string: "https://vk.com")!),
                                        PageItem(title: "Google Search", value: URL(string: "https://google.com")!),
                                        PageItem(title: nil, value: URL(string: "https://apple.com")!)
                ]),
                isClearing: false
            )
        ) {
            SearchHistory()
        }
    )
}
