//
//  AdMobLiveKey.swift
//  MagicSecurity
//
//  Created by User on 22.5.25.
//

import ComposableArchitecture
import GoogleMobileAds
import UIKit

@available(iOSApplicationExtension, unavailable)
extension AdMobClient: DependencyKey {
    public static let liveValue = Self(
        initialize: {
            await MobileAds.shared.start()
            await InterstitialAdManager.shared.initialize()
        },
        loadInterstitialAd: { adUnitId in
            try await InterstitialAdManager.shared.loadAd(adUnitId: adUnitId)
        },
        showInterstitialAd: {
            await InterstitialAdManager.shared.showAd()
        },
        isInterstitialAdReady: {
            MainActor.assumeIsolated {
                InterstitialAdManager.shared.isAdReady()
            }
        }
    )
}

@MainActor
private class InterstitialAdManager: NSObject {
    static let shared = InterstitialAdManager()
    
    private var interstitialAd: InterstitialAd?
    private var isLoading = false
    private var currentAdUnitId: String?
    private var showAdContinuation: CheckedContinuation<Bool, Never>?
    
    private override init() {
        super.init()
    }
    
    func initialize() async {
        do {
            try await loadAd(adUnitId: APIKeys.interstitialAdUnitID)
        } catch {
            print("Failed to initialize ad: \(error)")
        }
    }
    
    func loadAd(adUnitId: String) async throws {
        guard !isLoading else { return }
        
        isLoading = true
        currentAdUnitId = adUnitId
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let request = Request()
            InterstitialAd.load(with: adUnitId, request: request) { [weak self] ad, error in
                Task { @MainActor in
                    self?.isLoading = false
                    
                    if let error = error {
                        continuation.resume(throwing: AdMobClient.AdError.failedToLoad(error.localizedDescription))
                    } else {
                        self?.interstitialAd = ad
                        self?.interstitialAd?.fullScreenContentDelegate = self
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    func showAd() async -> Bool {
        guard let interstitialAd = interstitialAd else {
            handleAdNotReady()
            return false
        }
        
        guard let presentingViewController = findTopViewController() else {
            print("Could not find a suitable view controller to present ad from")
            return false
        }
        
        return await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            showAdContinuation = continuation
            interstitialAd.present(from: presentingViewController)
        }
    }
    
    private func findTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        return findTopViewController(from: window.rootViewController)
    }
    
    private func findTopViewController(from viewController: UIViewController?) -> UIViewController? {
        if let presentedViewController = viewController?.presentedViewController {
            return findTopViewController(from: presentedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController {
            return findTopViewController(from: navigationController.visibleViewController)
        }
        
        if let tabBarController = viewController as? UITabBarController {
            return findTopViewController(from: tabBarController.selectedViewController)
        }
        
        return viewController
    }
    
    func isAdReady() -> Bool {
        return interstitialAd != nil && !isLoading
    }
    
    private func handleAdNotReady() {
        if !isLoading {
            Task {
                let adUnitId = currentAdUnitId ?? APIKeys.interstitialAdUnitID
                try? await loadAd(adUnitId: adUnitId)
            }
        }
    }
    
    private func prepareNextAd() {
        Task {
            let adUnitId = currentAdUnitId ?? APIKeys.interstitialAdUnitID
            try? await loadAd(adUnitId: adUnitId)
        }
    }
}

// MARK: - FullScreenContentDelegate
extension InterstitialAdManager: FullScreenContentDelegate {
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("Ad did record impression.")
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present full screen content with error: \(error.localizedDescription)")
        interstitialAd = nil
        showAdContinuation?.resume(returning: false)
        showAdContinuation = nil
        prepareNextAd()
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        interstitialAd = nil
        showAdContinuation?.resume(returning: true)
        showAdContinuation = nil
        prepareNextAd()
    }
}
