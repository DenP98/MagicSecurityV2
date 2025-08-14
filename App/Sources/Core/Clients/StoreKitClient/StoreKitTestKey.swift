//
//  TestKey.swift
//  MagicSecurity
//
//  Created by User on 13.04.25.
//

import Dependencies
import StoreKit

extension DependencyValues {
    public var storeKitClient: StoreKitClient {
        get { self[StoreKitClient.self] }
        set { self[StoreKitClient.self] = newValue }
    }
}

extension StoreKitClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self()
}

extension StoreKitClient {
    public static let noop = Self(
        requestProducts: { _ in [] },
        purchase: { _ in throw CancellationError() },
        restore: { },
        transactionUpdates: { AsyncStream<VerificationResult<StoreKit.Transaction>> { _ in } },
        requestReview: { },
        validateSubscription: { false }
    )
}
