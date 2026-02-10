//
//  MoodMomentsApp.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct MoodMomentsApp: App {
    private let container: ModelContainer
    private let notificationHandler: NotificationHandler

    init() {
        
        do {
            container = try ModelContainer(for: Moment.self, PendingCheckin.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        

        // Hold a strong reference (UNUserNotificationCenter delegate is weak)
        notificationHandler = NotificationHandler(container: container)
        UNUserNotificationCenter.current().delegate = notificationHandler

        NotificationService.registerCategories()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(container)
    }
}
