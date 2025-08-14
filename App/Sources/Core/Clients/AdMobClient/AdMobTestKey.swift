//
//  AdMobTestKey.swift
//  MagicSecurity
//
//  Created by User on 22.5.25.
//

import ComposableArchitecture

extension DependencyValues {
    public var adMobClient: AdMobClient {
        get { self[AdMobClient.self] }
        set { self[AdMobClient.self] = newValue }
    }
}

extension AdMobClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self()
}

extension AdMobClient {
    public static let noop = Self(
        initialize: {},
        loadInterstitialAd: { _ in },
        showInterstitialAd: { false },
        isInterstitialAdReady: { false }
    )
}
