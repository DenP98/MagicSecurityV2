//
//  NotificationLiveKey.swift
//  MagicSecurity
//
//  Created by User on 29.05.25.
//

import UserNotifications
import ComposableArchitecture

extension NotificationClient: DependencyKey {
    public static let liveValue = NotificationClient(
        requestAuthorization: {
            let center = UNUserNotificationCenter.current()
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        },
        scheduleLocalNotification: { title, body, timeInterval in
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            try await UNUserNotificationCenter.current().add(request)
        },
        scheduleDelayedNotification: { title, body, timeInterval in
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: "delayed_notification", content: content, trigger: trigger)
            
            try await UNUserNotificationCenter.current().add(request)
        },
        scheduleDailyNotification: { title, body, hour, minute in
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "daily_notification", content: content, trigger: trigger)
            
            try await UNUserNotificationCenter.current().add(request)
        },
        cancelAllNotifications: {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        },
        hasPermission: {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            return settings.authorizationStatus == .authorized
        }
    )
}
