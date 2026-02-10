//
//  InsightsView.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Query private var moments: [Moment]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Average score by category")
                        .font(.headline)

                    Chart(averageByCategory) { item in
                        BarMark(
                            x: .value("Category", item.category.displayName),
                            y: .value("Avg", item.avg)
                        )
                    }
                    .frame(height: 260)

                    Text("Total moments: \(moments.count)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Insights")
        }
    }

    struct AvgItem: Identifiable {
        let id = UUID()
        let category: SceneCategory
        let avg: Double
    }

    private var averageByCategory: [AvgItem] {
        let grouped = Dictionary(grouping: moments) { $0.sceneCategory }
        return SceneCategory.allCases.map { cat in
            let ms = grouped[cat] ?? []
            let scores = ms.compactMap { $0.score }
            let avg = scores.isEmpty ? 0 : Double(scores.reduce(0, +)) / Double(scores.count)
            return AvgItem(category: cat, avg: avg)
        }
    }
}
