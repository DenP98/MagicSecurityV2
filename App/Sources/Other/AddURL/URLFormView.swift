//
//  URLFormView.swift
//  MagicSecurity
//
//  Created by User on 26.04.25.
//


import SwiftUI
import ComposableArchitecture

struct URLFormView: View {
    @Perception.Bindable var store: StoreOf<URLForm>
    
    init(store: StoreOf<URLForm>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("enter_url".localized)
                        .font(.headline)
                        .foregroundStyle(.designSystem(.textPrimary))
                    
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.designSystem(.textDescription))
                        
                        TextField("https://example.com", text: $store.url)
                            .textFieldStyle(.plain)
                            .textContentType(.URL)
                            .autocapitalization(.none)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white)
                    )
                    
                    if !store.url.isEmpty && !store.isURLValid {
                        Text("Please enter a valid URL")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal)
                
                Spacer()
                
                RoundedButton(buttonText: store.mode == .add ? "add_url".localized : "edit_url".localized) {
                    store.send(.addTapped)
                }
                .padding(.bottom)
                .opacity(store.isURLValid ? 1 : 0.6)
                
            }
            .background(.designSystem(.background))
            .navigationTitle(store.mode == .add ? "add_url".localized : "edit_url".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized) {
                        store.send(.cancelTapped)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        URLFormView(
            store: Store(
                initialState: URLForm.State(mode: .add)
            ) {
                URLForm()
            }
        )
    }
}
