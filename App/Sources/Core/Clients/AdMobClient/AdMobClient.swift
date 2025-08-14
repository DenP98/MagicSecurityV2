//
//  AdMobClient.swift
//  MagicSecurity
//
//  Created by User on 22.5.25.
//

import Foundation
import DependenciesMacros

@DependencyClient
public struct AdMobClient: Sendable {
    public var initialize: @Sendable () async -> Void
    public var loadInterstitialAd: @Sendable (String) async throws -> Void
    public var showInterstitialAd: @Sendable () async -> Bool = { false }
    public var isInterstitialAdReady: @Sendable () -> Bool = { false }
    
    public enum AdError: Error, Equatable {
        case notReady
        case failedToLoad(String)
        case failedToShow(String)
    }
}
