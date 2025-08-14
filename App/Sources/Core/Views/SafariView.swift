//
//  SafariView.swift
//  MagicSecurity
//
//  Created by User on 18.04.25.
//

import SwiftUI
import SafariServices
import ComposableArchitecture

@Reducer
public struct Safari: Sendable {
    @ObservableState
    public struct State: Equatable {
        let url: URL
        
        public init(url: URL) {
            self.url = url
        }
    }
    
    public enum Action {
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { _, _ in .none }
    }
}

public struct SafariView: UIViewControllerRepresentable {
    private let store: StoreOf<Safari>
    
    public init(store: StoreOf<Safari>) {
        self.store = store
    }
    
    public func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: store.url)
    }
    
    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
