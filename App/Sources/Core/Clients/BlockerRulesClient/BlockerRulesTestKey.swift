//
//  BlockerRulesTestKey.swift
//  MagicSecurity
//
//  Created by User on 22.04.25.
//

import Dependencies

extension DependencyValues {
    public var blockerRulesService: BlockerRulesClient {
        get { self[BlockerRulesClient.self] }
        set { self[BlockerRulesClient.self] = newValue }
    }
}

extension BlockerRulesClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self()
}

extension BlockerRulesClient {
    public static let noop = Self(
        updateRules: { _ in },
        getCurrentFilters: { [] },
        loadBlackList: { [] },
        updateBlackList: { _ in },
        loadWhiteList: { [] },
        updateWhiteList: { _ in }
    )
}
