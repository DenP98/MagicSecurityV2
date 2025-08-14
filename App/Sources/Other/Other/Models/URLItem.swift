//
//  URLItem.swift
//  MagicSecurity
//
//  Created by User on 28.04.25.
//

import Foundation

public struct URLItem: Identifiable, Equatable, Sendable, Codable {
    public let id: UUID
    let value: URL
    
    init(id: UUID = UUID(), value: URL) {
        self.id = id
        self.value = value
    }
}
