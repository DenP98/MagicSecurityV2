//
//  NotificationTestKey.swift
//  MagicSecurity
//
//  Created by User on 29.05.25.
//

import Dependencies

extension DependencyValues {
    public var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}

extension NotificationClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self()
}

extension NotificationClient {
    public static let noop = Self(
        requestAuthorization: { true },
        scheduleLocalNotification: { _, _, _ in },
        scheduleDelayedNotification: { _, _, _ in },
        scheduleDailyNotification: { _, _, _, _ in },
        cancelAllNotifications: { },
        hasPermission: { true }
    )
}
