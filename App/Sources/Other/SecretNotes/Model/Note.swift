//
//  Note.swift
//  MagicSecurity
//
//  Created by User on 30.04.25.
//

import Foundation

extension URL {
    static let secretNotesURL = Self.documentsDirectory.appending(component: "secret-notes.json")
}

public struct Note: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    var title: String
    var text: String
    let date: Date
    
    init(id: UUID = UUID(), title: String = "", text: String, date: Date = Date()) {
        self.id = id
        self.title = title
        self.text = text
        self.date = date
    }
}
