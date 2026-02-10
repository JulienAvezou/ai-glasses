//
//  MomentDetailView.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import SwiftUI
import SwiftData

struct MomentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var moment: Moment

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let path = moment.overlayPath,
                   let ui = UIImage(contentsOfFile: path) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Picker("Category", selection: $moment.sceneCategoryRaw) {
                        ForEach(SceneCategory.allCases) { c in
                            Text(c.displayName).tag(c.rawValue)
                        }
                    }
                    .pickerStyle(.menu)

                    Stepper(value: Binding(
                        get: { moment.score ?? 3 },
                        set: { moment.score = $0; moment.scoreSource = "manual" }
                    ), in: 1...5) {
                        Text("Score: \(moment.score ?? 0)/5")
                    }

                    Text("Score source: \(moment.scoreSource)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button("Save Changes") {
                        try? modelContext.save()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .navigationTitle("Moment")
        .navigationBarTitleDisplayMode(.inline)
    }
}
