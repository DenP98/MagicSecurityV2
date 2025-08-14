//
//  SecretNotes.swift
//  MagicSecurity
//
//  Created by User on 30.04.25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct SecretNotes: Sendable {
    @Reducer(state: .equatable)
    public enum Destination {
        case detail(SecretNoteDetail)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents public var destination: Destination.State?
        @Shared private(set) var notes: [Note]
        
        public init(notes: Shared<[Note]> = .init(value: [])) {
            self._notes = notes
        }
    }
    
    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case addButtonTapped
        case noteTapped(Note)
        case deleteNote(Note)
        case delegate(Delegate)
        
        public enum Delegate {
            case notesUpdated([Note])
        }
    }
    
    @Dependency(\.uuid) var uuid
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                let newNote = Note(id: uuid(), title: "", text: "", date: .now)
                state.destination = .detail(SecretNoteDetail.State(note: newNote))
                return .none
                
            case let .noteTapped(note):
                state.destination = .detail(SecretNoteDetail.State(note: note, focus: nil))
                return .none
                
            case let .deleteNote(note):
                var updatedNotes = state.notes
                updatedNotes.removeAll { $0.id == note.id }
                return .send(.delegate(.notesUpdated(updatedNotes)))
                
            case let .destination(.presented(.detail(.delegate(.noteUpdated(note))))):
                var updatedNotes = state.notes
                if let index = updatedNotes.firstIndex(where: { $0.id == note.id }) {
                    updatedNotes[index] = note
                } else {
                    updatedNotes.insert(note, at: 0)
                }
                return .send(.delegate(.notesUpdated(updatedNotes)))
                
            case let .destination(.presented(.detail(.delegate(.noteDeleted(note))))):
                return .send(.deleteNote(note))
                
            case .destination, .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
