//
//  URLListView.swift
//  MagicSecurity
//
//  Created by User on 25.04.25.
//

import SwiftUI
import ComposableArchitecture

public struct URLListView: View {
    @Perception.Bindable var store: StoreOf<URLList>
    
    public init(store: StoreOf<URLList>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ZStack {
                Color
                    .designSystem(.background)
                    .ignoresSafeArea()
                
                VStack {
                    if store.urls.isEmpty {
                        Spacer()
                        Image("URLList/empty_list")
                            .padding(.bottom, 48)
                        Text(store.type == .black ? "empty_black_list".localized : "empty_white_list".localized)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.designSystem(.textDescription))
                        Spacer()
                    } else {
                        List {
                            Section("URL") {
                                ForEach(store.urls) { url in
                                    HStack {
                                        Image("URLList/globe_icon")
                                            .foregroundColor(.blue)
                                        Text(url.value.absoluteString)
                                            .font(.system(size: 17))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.designSystem(.chevron))
                                    }
                                    .onTapGesture {
                                        store.send(.urlTapped(url))
                                    }
                                    .padding([.top, .bottom], 6)
                                }
                                .onDelete { indexSet in
                                    guard let index = indexSet.first else {
                                        return
                                    }
                                    store.send(.deleteURL(store.urls[index]))
                                }
                            }
                            .font(.system(size: 15, weight: .bold))
                        }
                        .listStyle(.insetGrouped)
                        .frame(maxWidth: 450)
                    }
                    
                    RoundedButton(buttonText: "add_url".localized) {
                        store.send(.addURLTapped)
                    }
                    .padding(.bottom)
                    .frame(maxWidth: 450)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(store.type.titleKey.localized)
            .sheet(
                item: $store.scope(state: \.destination?.urlForm,
                                   action: \.destination.urlForm)
            ) { store in
                NavigationStack {
                    URLFormView(store: store)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        URLListView(
            store: Store(
                initialState: URLList.State(
                    type: .black,
                    urls: .init(
                        value: [
                            .init(value: URL(string: "http://google.com")!),
                            .init(value: URL(string: "http://instagram.com")!)
                        ]
                    )
                )
            ) {
                URLList()
            }
        )
    }
}

#Preview {
    NavigationStack {
        URLListView(
            store: Store(
                initialState: URLList.State(type: .white)
            ) {
                URLList()
            }
        )
    }
}
