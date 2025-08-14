//
//  LiveKey.swift
//  MagicSecurity
//
//  Created by User on 12.04.25.
//

import ComposableArchitecture
import StoreKit

@available(iOSApplicationExtension, unavailable)
extension StoreKitClient: DependencyKey {
    public static let liveValue = Self(
        requestProducts: { productIds in
            return try await Product.products(for: productIds)
        },
        purchase: { product in
            return try await product.purchase()
        },
        restore: {
            try await AppStore.sync()
        },
        transactionUpdates: {
            AsyncStream { continuation in
                Task {
                    for await transaction in StoreKit.Transaction.updates {
                        continuation.yield(transaction)
                    }
                }
            }
        },
        requestReview: {
            guard
                let scene = await UIApplication.shared.connectedScenes
                    .first(where: { $0 is UIWindowScene })
                    as? UIWindowScene
            else { return }
            await SKStoreReviewController.requestReview(in: scene)
        },
        validateSubscription: {
            for await transaction in StoreKit.Transaction.currentEntitlements {
                guard case .verified(let verifiedTransaction) = transaction,
                      verifiedTransaction.productType == .autoRenewable else {
                    continue
                }
                
                return !verifiedTransaction.isUpgraded
            }
            return false
        }
    )
}
