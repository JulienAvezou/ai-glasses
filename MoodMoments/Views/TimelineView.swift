//
//  TimelineView.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Moment.createdAt, order: .reverse) private var moments: [Moment]

    var body: some View {
        NavigationStack {
            List {
                ForEach(moments, id: \.id) { m in
                    NavigationLink {
                        MomentDetailView(moment: m)
                    } label: {
                        HStack(spacing: 12) {
                            overlayThumb(for: m)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(m.sceneCategory.displayName) · \(m.score.map { "\($0)/5" } ?? "—")")
                                    .font(.headline)
                                Text(m.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Timeline")
        }
    }

    @ViewBuilder
    private func overlayThumb(for m: Moment) -> some View {
        if let path = m.overlayPath,
           let ui = UIImage(contentsOfFile: path) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray.opacity(0.2))
                .frame(width: 64, height: 64)
                .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
        }
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets {
            modelContext.delete(moments[i])
        }
        try? modelContext.save()
    }
}
