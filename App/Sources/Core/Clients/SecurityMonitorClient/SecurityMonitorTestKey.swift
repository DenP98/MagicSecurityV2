//
//  SecurityMonitorTestKey.swift
//  MagicSecurity
//
//  Created by User on 29.04.25.
//

import Dependencies

extension DependencyValues {
    public var securityMonitor: SecurityMonitorClient {
        get { self[SecurityMonitorClient.self] }
        set { self[SecurityMonitorClient.self] = newValue }
    }
}

extension SecurityMonitorClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self()
}

extension SecurityMonitorClient {
    public static let noop = Self(
        monitorConfig: { .init() },
        updateMonitorConfig: { _ in }
    )
}
