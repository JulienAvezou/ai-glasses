//
//  NotificationService.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import Foundation
import UserNotifications

enum NotificationService {
    static let categoryId = "MOOD_SCORE_CATEGORY"

    static func registerCategories() {
        let actions = (1...5).map { n in
            UNNotificationAction(
                identifier: "SCORE_\(n)",
                title: "\(n)",
                options: [.authenticationRequired]
            )
        }
        let category = UNNotificationCategory(
            identifier: categoryId,
            actions: actions,
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    static func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }

    /// For debugging you can set seconds=60. For real MVP hour prompts use 3600.
    static func scheduleRepeatingPrompt(every seconds: TimeInterval = 60) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Quick check-in"
        content.body = "Take a glasses photo now, then rate the moment."
        content.sound = .default
        content.categoryIdentifier = categoryId

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(60, seconds), repeats: true)
        let request = UNNotificationRequest(identifier: "HOURLY_PROMPT", content: content, trigger: trigger)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["HOURLY_PROMPT"])
        try await UNUserNotificationCenter.current().add(request)
    }
}
