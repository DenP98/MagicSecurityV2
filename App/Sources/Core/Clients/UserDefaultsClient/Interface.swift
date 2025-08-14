//
//  Interface.swift
//  MagicSecurity
//
//  Created by User on 11.04.25.
//

import Foundation
import Dependencies
import DependenciesMacros

extension DependencyValues {
    public var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}

public enum UserClassesKeys: String {
    case hasShownFirstLaunchPaywallKey
    case hasActiveSubscriptionKey
    case multiplayerOpensCount
    case passwordHashKey
    case hasScheduledFirstCloseNotificationKey
}

@DependencyClient
public struct UserDefaultsClient: Sendable {
    public var boolForKey: @Sendable (UserClassesKeys) -> Bool = { _ in false }
    public var dataForKey: @Sendable (UserClassesKeys) -> Data?
    public var doubleForKey: @Sendable (UserClassesKeys) -> Double = { _ in 0 }
    public var integerForKey: @Sendable (UserClassesKeys) -> Int = { _ in 0 }
    public var stringForKey: @Sendable (UserClassesKeys) -> String? = { _ in nil }
    public var remove: @Sendable (UserClassesKeys) async -> Void
    public var setBool: @Sendable (Bool, UserClassesKeys) async -> Void
    public var setData: @Sendable (Data?, UserClassesKeys) async -> Void
    public var setDouble: @Sendable (Double, UserClassesKeys) async -> Void
    public var setInteger: @Sendable (Int, UserClassesKeys) async -> Void
    public var setString: @Sendable (String?, UserClassesKeys) async -> Void
    
    public var hasShownFirstLaunchPaywall: Bool {
        self.boolForKey(.hasShownFirstLaunchPaywallKey)
    }
    
    public func setHasShownFirstLaunchPaywall() async {
        await self.setBool(true, .hasShownFirstLaunchPaywallKey)
    }
    
    public var hasActiveSubscription: Bool {
        self.boolForKey(.hasActiveSubscriptionKey)
    }
    
    public func setHasActiveSubscription(_ bool: Bool) async {
        await self.setBool(bool, .hasActiveSubscriptionKey)
    }
    
    public var passwordHash: String? {
        self.stringForKey(.passwordHashKey)
    }
    
    public func setPasswordHash(_ hash: String?) async {
        await self.setString(hash, .passwordHashKey)
    }
    
    public var hasScheduledFirstCloseNotification: Bool {
        self.boolForKey(.hasScheduledFirstCloseNotificationKey)
    }
    
    public func setHasScheduledFirstCloseNotification() async {
        await self.setBool(true, .hasScheduledFirstCloseNotificationKey)
    }
}
