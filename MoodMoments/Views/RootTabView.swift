//
//  RootTabView.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            CaptureView()
                .tabItem { Label("Capture", systemImage: "camera") }

            TimelineView()
                .tabItem { Label("Timeline", systemImage: "list.bullet.rectangle") }

            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.bar") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
