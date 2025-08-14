//
//  Paywall.swift
//  MagicSecurity
//
//  Created by User on 17.05.25.
//

import ComposableArchitecture
import SwiftUI
import StoreKit

@Reducer
public struct Paywall: Sendable {
    @ObservableState
    public struct State: Equatable {
        public var selectedPlan: Plan
        public var isFreeTrialEnabled: Bool
        var weeklyProduct: Product?
        var yearlyProduct: Product?
        public var isLoading: Bool
        public var isFirstPaywallAfterOnboarding: Bool
        public var isShowingAd: Bool
        
        @Presents public var safari: Safari.State?
        
        public var weeklyPrice: String {
            guard let weeklyProduct else { return "$xx" }
            return weeklyProduct.displayPrice
        }
        
        public var yearlyPrice: String {
            guard let yearlyProduct else { return "$xx" }
            return yearlyProduct.displayPrice
        }
        
        public var discountSize: String {
            guard let weeklyProduct,
                  let yearlyProduct else {
                return String(format: "save_percents".localized, "0%")
            }
            
            let yearlyWeaklyPrice = weeklyProduct.price * 52
            let discount = 1 - (yearlyProduct.price / yearlyWeaklyPrice)
            
            return String(format: "save_percents".localized, Self.discountFormatter.string(from: discount as NSDecimalNumber) ?? "0%")
        }
        
        private static let discountFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 0
            return  formatter
        }()
        
        public init(
            selectedPlan: Plan = .weekly,
            isFreeTrialEnabled: Bool = true,
            weeklyProduct: Product? = nil,
            yearlyProduct: Product? = nil,
            safari: Safari.State? = nil,
            isLoading: Bool = false,
            isFirstPaywallAfterOnboarding: Bool = false,
            isShowingAd: Bool = false
        ) {
            self.selectedPlan = selectedPlan
            self.isFreeTrialEnabled = isFreeTrialEnabled
            self.weeklyProduct = weeklyProduct
            self.yearlyProduct = yearlyProduct
            self.safari = safari
            self.isLoading = isLoading
            self.isFirstPaywallAfterOnboarding = isFirstPaywallAfterOnboarding
            self.isShowingAd = isShowingAd
        }
    }
    
    public enum Action {
        case onAppear
        case selectPlan(Plan)
        case toggleFreeTrialSwitched
        case continueButtonTapped
        case skipTapped
        case restoreTapped
        case privacyPolicyTapped
        case termsOfUseTapped
        case safari(PresentationAction<Safari.Action>)
        case productsLoaded([Product])
        case purchaseCompleted(Result<Product.PurchaseResult, Error>)
        case restoreCompleted(Result<Void, Error>)
        case transactionUpdated(VerificationResult<StoreKit.Transaction>)
        case adLoadingStarted
        case adShown(Bool)
        case delegate(Delegate)
        
        public enum Delegate {
            case skipSelected
            case purchaseCompleted
        }
    }
    
    public enum Plan: Equatable, Sendable {
        case weekly
        case yearly
        
        var productIdentifier: String {
            #warning("Update with actual product identifiers")
            switch self {
            case .weekly:
                return "com.apprix.magicsecurity.weekly"
            case .yearly:
                return "com.apprix.magicsecurity.yearly"
            }
        }
    }
    
    @Dependency(\.storeKitClient) var storeKitClient
    @Dependency(\.adMobClient) var adMobClient
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await withTaskGroup(of: Void.self) { group in
                        group.addTask {
                            do {
                                let productIds = Set([Plan.weekly.productIdentifier, Plan.yearly.productIdentifier])
                                let products = try await storeKitClient.requestProducts(productIds)
                                await send(.productsLoaded(products))
                            } catch {
                                await send(.productsLoaded([]))
                            }
                        }
                        
                        group.addTask {
                            for await transaction in storeKitClient.transactionUpdates() {
                                await send(.transactionUpdated(transaction))
                            }
                        }
                        
                        group.addTask {
                            try? await adMobClient.loadInterstitialAd(APIKeys.interstitialAdUnitID)
                            await send(.adLoadingStarted)
                        }
                    }
                }
                
            case let .productsLoaded(products):
                state.isLoading = false
                
                for product in products {
                    if product.id == Plan.weekly.productIdentifier {
                        state.weeklyProduct = product
                    } else if product.id == Plan.yearly.productIdentifier {
                        state.yearlyProduct = product
                    }
                }
                return .none
                
            case let .selectPlan(plan):
                state.selectedPlan = plan
                state.isFreeTrialEnabled = plan == .weekly
                return .none
                
            case .toggleFreeTrialSwitched:
                state.isFreeTrialEnabled.toggle()
                state.selectedPlan = state.isFreeTrialEnabled ? .weekly : .yearly
                return .none
                
            case .continueButtonTapped:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                
                let product = state.selectedPlan == .weekly ? state.weeklyProduct : state.yearlyProduct
                guard let product else {
                    state.isLoading = false
                    return .none
                }
                
                return .run { send in
                    do {
                        let result = try await storeKitClient.purchase(product)
                        await send(.purchaseCompleted(.success(result)))
                    } catch {
                        await send(.purchaseCompleted(.failure(error)))
                    }
                }
                
            case .skipTapped:
                if state.isFirstPaywallAfterOnboarding {
                    return .run { [dismiss] send in
                        await send(.delegate(.skipSelected))
                        await dismiss()
                    }
                } else {
                    state.isShowingAd = true
                    return .run { send in
                        let adShown = await adMobClient.showInterstitialAd()
                        await send(.adShown(adShown))
                    }
                }
                
            case .adShown:
                state.isShowingAd = false
                return .run { [dismiss] send in
                    await send(.delegate(.skipSelected))
                    await dismiss()
                }
                
            case .restoreTapped:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                
                return .run { send in
                    do {
                        try await storeKitClient.restore()
                        await send(.restoreCompleted(.success(())))
                    } catch {
                        await send(.restoreCompleted(.failure(error)))
                    }
                }
                
            case let .purchaseCompleted(result):
                state.isLoading = false
                switch result {
                case .success(let purchaseResult):
                    switch purchaseResult {
                    case .success(let verificationResult):
                        switch verificationResult {
                        case .verified(let transaction):
                            return .run { [dismiss] send in
                                await userDefaults.setHasActiveSubscription(true)
                                await transaction.finish()
                                await send(.delegate(.purchaseCompleted))
                                await dismiss()
                            }
                        case .unverified:
                            return .none
                        }
                    case .userCancelled, .pending:
                        return .none
                    @unknown default:
                        return .none
                    }
                case .failure:
                    return .none
                }
                
            case let .restoreCompleted(result):
                state.isLoading = false
                switch result {
                case .success:
                    return .concatenate(
                        .run { [userDefaults] _ in
                            await userDefaults.setHasActiveSubscription(true)
                        },
                        .send(.delegate(.purchaseCompleted))
                    )
                case .failure:
                    return .none
                }
                
            case let .transactionUpdated(verificationResult):
                switch verificationResult {
                case .verified(let transaction):
                    return .run { [userDefaults] _ in
                        await userDefaults.setHasActiveSubscription(true)
                        await transaction.finish()
                    }
                case .unverified:
                    return .none
                }
                
            case .privacyPolicyTapped:
                state.safari = Safari.State(url: URL(string: "https://example.com/privacy")!)
                return .none
                
            case .termsOfUseTapped:
                state.safari = Safari.State(url: URL(string: "https://example.com/terms")!)
                return .none
                
            case .adLoadingStarted:
                return .none
                
            case .delegate, .safari:
                return .none
            }
        }
        .ifLet(\.$safari, action: \.safari) {
            Safari()
        }
    }
}
