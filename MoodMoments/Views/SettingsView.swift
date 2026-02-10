//
//  SettingsView.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import SwiftUI

struct SettingsView: View {
    @State private var notifEnabled = false
    @State private var intervalSeconds: Double = 3600
    @State private var info: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Notifications") {
                    Toggle("Enable hourly prompts", isOn: $notifEnabled)
                        .onChange(of: notifEnabled) { _, newValue in
                            if newValue {
                                Task { await enableNotifications() }
                            }
                        }

                    HStack {
                        Text("Interval")
                        Spacer()
                        Text(intervalSeconds == 3600 ? "1 hour" : "\(Int(intervalSeconds))s")
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $intervalSeconds, in: 60...3600, step: 60)
                    Text("For debugging, set to 60s. For real use, keep 3600s.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button("Schedule prompt now") {
                        Task { await schedule() }
                    }
                }

                if let info {
                    Section("Status") {
                        Text(info)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func enableNotifications() async {
        do {
            let ok = try await NotificationService.requestAuthorization()
            info = ok ? "Notifications enabled." : "Notifications not authorized."
        } catch {
            info = "Notification error: \(error.localizedDescription)"
        }
    }

    private func schedule() async {
        do {
            try await NotificationService.scheduleRepeatingPrompt(every: intervalSeconds)
            info = "Scheduled repeating prompt."
        } catch {
            info = "Schedule error: \(error.localizedDescription)"
        }
    }
}
