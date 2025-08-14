//
//  BlockerRulesClient.swift
//  MagicSecurity
//
//  Created by User on 22.04.25.
//

import ComposableArchitecture
import Foundation

@DependencyClient
public struct BlockerRulesClient: Sendable {
    public var updateRules: @Sendable (FilterOptions) async -> Void
    public var getCurrentFilters: @Sendable () -> FilterOptions = { [] }
    
    public var loadBlackList: @Sendable () -> [URL] = { [] }
    public var updateBlackList: @Sendable ([URL]) async -> Void
    public var loadWhiteList: @Sendable () -> [URL] = { [] }
    public var updateWhiteList: @Sendable ([URL]) async -> Void
}
