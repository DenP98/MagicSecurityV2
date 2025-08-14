//
//  Client.swift
//  MagicSecurity
//
//  Created by User on 12.04.25.
//

import StoreKit
import DependenciesMacros

@DependencyClient
public struct StoreKitClient: Sendable {
    public var requestProducts: @Sendable (Set<String>) async throws -> [Product] = { _ in [] }
    public var purchase: @Sendable (Product) async throws -> Product.PurchaseResult = { _ in throw CancellationError() }
    public var restore: @Sendable () async throws -> Void = { }
    public var transactionUpdates: @Sendable () -> AsyncStream<VerificationResult<Transaction>> = { 
        AsyncStream { _ in } 
    }
    public var requestReview: @Sendable () async -> Void = { }
    public var validateSubscription: @Sendable () async -> Bool = { false }
}
