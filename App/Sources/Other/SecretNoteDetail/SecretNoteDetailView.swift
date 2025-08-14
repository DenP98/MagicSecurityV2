//
//  SecretNoteDetailView.swift
//  MagicSecurity
//
//  Created by User on 30.04.25.
//

import ComposableArchitecture
import SwiftUI

public struct SecretNoteDetailView: View {
    @Perception.Bindable var store: StoreOf<SecretNoteDetail>
    @FocusState var focus: SecretNoteDetail.State.Field?
    
    public init(store: StoreOf<SecretNoteDetail>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 16) {
                TextField("", text: $store.note.title)
                    .font(.system(size: 22, weight: .bold))
                    .focused($focus, equals: .title)
                    .padding(.leading, 4)
                    .submitLabel(.next)
                    .onSubmit {
                        store.send(.nextTapped)
                    }
                
                TextEditor(text: $store.note.text)
                    .font(.system(size: 17, weight: .regular))
                    .focused($focus, equals: .text)
            }
            .padding(24)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                store.send(.keyboardVisibilityChanged(true))
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                store.send(.keyboardVisibilityChanged(false))
            }
            .frame(maxWidth: 500)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if store.isKeyboardVisible {
                        Button("done".localized) {
                            store.send(.saveButtonTapped)
                        }
                        .bold()
                    } else {
                        Button("delete".localized) {
                            store.send(.deleteButtonTapped)
                        }
                        .bold()
                    }
                }
            }
            .bind($store.focus, to: $focus)
        }
    }
}

#Preview {
    NavigationStack {
        SecretNoteDetailView(
            store: Store(
                initialState: SecretNoteDetail.State(
                    note: Note(id: UUID(), title: "Title", text: ""))
            ) {
                SecretNoteDetail()
            }
        )
    }
}
