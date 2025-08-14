//
//  PageItem.swift
//  MagicSecurity
//
//  Created by User on 23.05.25.
//

import Foundation

extension URL {
    static let pageItemsURL = Self.documentsDirectory.appending(component: "page-items.json")
}

public struct PageItem: Identifiable, Equatable, Sendable, Codable {
    public let id: UUID
    let title: String?
    let value: URL
    
    init(id: UUID = UUID(), title: String?, value: URL) {
        self.id = id
        self.title = title
        self.value = value
    }
}
