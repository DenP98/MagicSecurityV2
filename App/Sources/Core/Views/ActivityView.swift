//
//  ActivityView.swift
//  MagicSecurity
//
//  Created by User on 30.04.25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
public struct Activity: Sendable {
    @ObservableState
    public struct State: Equatable {
        var text: String
        var url: URL
        var applicationActivities: [UIActivity]? = nil
        
        public init(text: String, url: URL, applicationActivities: [UIActivity]? = nil) {
            self.text = text
            self.url = url
            self.applicationActivities = applicationActivities
        }
    }
    
    public enum Action {
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { _, _ in .none }
    }
}

public struct ActivityView: UIViewControllerRepresentable {

    private let store: StoreOf<Activity>
    
    public init(store: StoreOf<Activity>) {
        self.store = store
    }

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: [store.text, store.url],
            applicationActivities: store.applicationActivities
        )
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}

}
