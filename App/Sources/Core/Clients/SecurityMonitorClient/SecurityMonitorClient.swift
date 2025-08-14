//
//  BlockerRulesClient.swift
//  MagicSecurity
//
//  Created by User on 28.04.25.
//

import DependenciesMacros

@DependencyClient
public struct SecurityMonitorClient: Sendable {
    public var monitorConfig: @Sendable () async -> SecurityMonitorConfig = { .init() }
    public var updateMonitorConfig: @Sendable (SecurityMonitorConfig) async -> Void
}
