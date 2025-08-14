//
//  NotificationClient.swift
//  MagicSecurity
//
//  Created by User on 29.05.25.
//

import Foundation
import UserNotifications
import ComposableArchitecture

@DependencyClient
public struct NotificationClient: Sendable {
    public var requestAuthorization: @Sendable () async throws -> Bool = { false }
    public var scheduleLocalNotification: @Sendable (_ title: String, _ body: String, _ timeInterval: TimeInterval) async throws -> Void = { _, _, _ in }
    public var scheduleDelayedNotification: @Sendable (_ title: String, _ body: String, _ timeInterval: TimeInterval) async throws -> Void = { _, _, _ in }
    public var scheduleDailyNotification: @Sendable (_ title: String, _ body: String, _ hour: Int, _ minute: Int) async throws -> Void = { _, _, _, _ in }
    public var cancelAllNotifications: @Sendable () async -> Void = { }
    public var hasPermission: @Sendable () async -> Bool = { false }
}
