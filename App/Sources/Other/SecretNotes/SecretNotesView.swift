//
//  SecretNotesView.swift
//  MagicSecurity
//
//  Created by User on 30.04.25.
//

import ComposableArchitecture
import SwiftUI

public struct SecretNotesView: View {
    @Perception.Bindable var store: StoreOf<SecretNotes>
    
    public init(store: StoreOf<SecretNotes>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack {
                if store.notes.isEmpty {
                    Spacer()
                    Image("SecretNotes/empty_notes")
                        .frame(width: 140, height: 180)
                        .padding(.bottom, 50)
                    
                    Text("you_dont_have_notes".localized)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.designSystem(.textDescription))
                    Spacer()
                } else {
                    List {
                        ForEach(store.notes) { note in
                            Button {
                                store.send(.noteTapped(note))
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(note.title)
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundStyle(.designSystem(.textSecondary))
                                        .lineLimit(1)
                                    Text(note.text)
                                        .font(.system(size: 15))
                                        .foregroundStyle(.designSystem(.textDescription))
                                        .lineLimit(1)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { indexSet in
                            if let index = indexSet.first {
                                store.send(.deleteNote(store.notes[index]))
                            }
                        }
                    }
                    .frame(maxWidth: 500)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.designSystem(.background))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("secret_notes_title".localized)
            .toolbar {
                Button("add".localized) {
                    store.send(.addButtonTapped)
                }
                .bold()
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.detail,
                                   action: \.destination.detail),
                destination: { store in
                    SecretNoteDetailView(store: store)
                }
            )
        }
    }
}

#Preview {
    NavigationStack {
        SecretNotesView(
            store: Store(
                initialState: SecretNotes.State(notes: .init(value: [
                    Note(id: UUID(), title: "Title", text: "Texfkdjfjdkfjdkjfdkfjdfkdfjdkfdjfdff kdjfkdjfjdjfdjfjdkfkjdkfjdt", date: Date()),
                    Note(id: UUID(), title: "Title", text: "Text", date: Date())
                ]))
            ) {
                SecretNotes()
            }
        )
    }
}

#Preview {
    NavigationStack {
        SecretNotesView(
            store: Store(
                initialState: SecretNotes.State()
            ) {
                SecretNotes()
            }
        )
    }
}
