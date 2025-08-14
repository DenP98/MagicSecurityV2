//
//  UIApplicationClient.swift
//  MagicSecurity
//
//  Created by User on 14.04.25.
//

import Dependencies

extension DependencyValues {
    public var applicationClient: UIApplicationClient {
        get { self[UIApplicationClient.self] }
        set { self[UIApplicationClient.self] = newValue }
    }
}

extension UIApplicationClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self()
}

extension UIApplicationClient {
    public static let noop = Self(
        open: { _, _ in false },
        openSettingsURLString: { "settings://magicsecurity/settings" }
    )
}
