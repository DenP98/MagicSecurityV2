//
//  Untitled.swift
//  MagicSecurity
//
//  Created by User on 24.04.25.
//

import Foundation

public struct FilterOptions: OptionSet, Codable, Sendable, Equatable {
    public let rawValue: Int
    
    public static let ads = FilterOptions(rawValue: 1 << 0)
    public static let tracking = FilterOptions(rawValue: 1 << 1)
    public static let scripts = FilterOptions(rawValue: 1 << 2)
    public static let adultSites = FilterOptions(rawValue: 1 << 3)
    public static let gambling = FilterOptions(rawValue: 1 << 4)
    public static let customFonts = FilterOptions(rawValue: 1 << 5)
    public static let socialButtons = FilterOptions(rawValue: 1 << 6)
    
    public static let all: FilterOptions = [.ads, .tracking, .scripts,
                                         .adultSites, .gambling,
                                         .customFonts, .socialButtons]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
