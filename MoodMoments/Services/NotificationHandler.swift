//
//  NotificationHandler.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import Foundation
import SwiftData
import UserNotifications

final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
        super.init()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        defer { completionHandler() }

        // Parse action identifier "SCORE_1"..."SCORE_5"
        guard response.actionIdentifier.hasPrefix("SCORE_"),
              let n = Int(response.actionIdentifier.replacingOccurrences(of: "SCORE_", with: "")),
              (1...5).contains(n) else { return }

        // Save PendingCheckin to SwiftData
        let context = ModelContext(container)
        context.insert(PendingCheckin(createdAt: .now, score: n))
        do { try context.save() } catch { /* ignore MVP */ }
    }

    // Show notifications while app is open
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
