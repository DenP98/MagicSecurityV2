//
//  AppDelegateReducer.swift
//  MagicSecurity
//
//  Created by User on 7.04.25.
//

import Foundation
import UIKit
import ComposableArchitecture
import AppTrackingTransparency
import ApphudSDK
import AppsFlyerLib
import FirebaseCore
import FirebaseAnalytics

@Reducer
public struct AppDelegateReducer: Sendable {
    public struct State: Equatable {
        public var hasRequestedNotificationPermission: Bool = false
        let appsFlyerHelper = AppsFlyerHelper()
        
        public init() {}
    }
    
    public enum Action {
        case didFinishLaunching(UIApplication)
        case requestNotificationPermission
        case notificationPermissionResponse(Bool)
        case quickActionTriggered(String)
    }
    
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.mailClient) var mailClient
    @Dependency(\.adMobClient) var adMobClient
    
    private let mailActionType = "support-email"
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didFinishLaunching(let application):
                return .merge(
                    .run { @MainActor [application] send in
                        guard let items = application.shortcutItems,
                              items.isEmpty else {
                            return
                        }
                        
                        let supportAction = UIApplicationShortcutItem(
                            type: mailActionType,
                            localizedTitle: "contact_support".localized,
                            localizedSubtitle: "send_email_to_support".localized,
                            icon: UIApplicationShortcutIcon(type: .mail),
                            userInfo: nil
                        )
                        
                        application.shortcutItems = [supportAction]
                    },
                    .run { [adMobClient, appsFlyerHelper = state.appsFlyerHelper] _ in
                        // INITIALIZE FIREBASE
                        FirebaseApp.configure()
                        // INITIALIZE APPHUD
                        await Apphud.start(
                            apiKey: APIKeys.apphudKey,
                            userID: nil,
                            observerMode: true
                        )
                        // INITIALIZE APPSFLYER
                        AppsFlyerLib.shared().appsFlyerDevKey = APIKeys.appsFlyerDevKey
                        AppsFlyerLib.shared().appleAppID = APIKeys.appsFlyerAppID
                        AppsFlyerLib.shared().delegate = appsFlyerHelper
                        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 10)
                        NotificationCenter.default.addObserver(
                            appsFlyerHelper,
                            selector: #selector(AppsFlyerHelper.sendLaunch),
                            name: UIApplication.didBecomeActiveNotification,
                            object: nil
                        )
                        // LINK ANALYTICS
                        await Analytics.setUserID(Apphud.userID())
                        if let instanceID = Analytics.appInstanceID() {
                            Apphud.setAttribution(data: nil, from: .firebase, identifer: instanceID, callback: nil)
                        }
                        // INITIALIZE ADMOB
                        await adMobClient.initialize()
                    }
                )
                
            case .requestNotificationPermission:
                guard !state.hasRequestedNotificationPermission else { return .none }
                state.hasRequestedNotificationPermission = true
                
                return .run { [notificationClient] send in
                    let _ = await requestTrackingAuthorization()
                    
                    do {
                        let granted = try await notificationClient.requestAuthorization()
                        await send(.notificationPermissionResponse(granted))
                    } catch {
                        await send(.notificationPermissionResponse(false))
                    }
                }
                
            case .notificationPermissionResponse:
                return .none
                
            case let .quickActionTriggered(actionType):
                guard actionType == mailActionType else {
                    return .none
                }
                
                return .run { _ in
                    #warning("change address")
                    await mailClient.presentMailComposer(
                        "support@magicsecurity.app",
                        "Magic Security Bug Report",
                        "Hi Magic Security team,\n\n"
                    )
                }
            }
        }
    }
    
    func requestTrackingAuthorization() async -> ATTrackingManager.AuthorizationStatus {
        await withCheckedContinuation { continuation in
            ATTrackingManager.requestTrackingAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }
}

final class AppsFlyerHelper: NSObject, Sendable {
    @objc func sendLaunch() {
        AppsFlyerLib.shared().start()
    }
}

extension AppsFlyerHelper: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        Apphud.setAttribution(
            data: ApphudAttributionData(rawData: conversionInfo),
            from: .appsFlyer,
            identifer: AppsFlyerLib.shared().getAppsFlyerUID(),
            callback: nil
        )
    }
    
    func onConversionDataFail(_ error: Error) {
        Apphud.setAttribution(
            data: ApphudAttributionData(rawData: ["error" : error.localizedDescription]),
            from: .appsFlyer,
            identifer: AppsFlyerLib.shared().getAppsFlyerUID()
        ) { _ in }
    }
}

