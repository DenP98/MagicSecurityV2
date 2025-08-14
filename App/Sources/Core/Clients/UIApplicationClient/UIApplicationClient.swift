//
//  UIApplicationClient.swift
//  MagicSecurity
//
//  Created by User on 10.05.25.
//

import Foundation
import DependenciesMacros
import UIKit

@DependencyClient
public struct UIApplicationClient: Sendable {
    public var open: @Sendable (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool = {
        @MainActor url, _ in await UIApplication.shared.open(url)
    }
    public var openSettingsURLString: @Sendable () async -> String = { UIApplication.openSettingsURLString }
}
