//
//  MomentPipeline.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import Foundation
import SwiftData
import UIKit

struct PipelineOutput {
    let suggestedScore: Int?
    let scoreSource: String
    let category: SceneCategory
    let sceneConfidence: Double
    let labelsJSON: String
    let overlayImage: UIImage
    let overlayPath: String
}

final class MomentPipeline {
    private let scene = SceneClassifier()
    private let hand = HandPoseScorer()
    private let overlay = OverlayRenderer()

    /// Tries to attach the closest PendingCheckin within `maxSeconds`.
    private func attachPendingScore(context: ModelContext, momentId: UUID, maxSeconds: TimeInterval = 600) -> Int? {
        let fetch = FetchDescriptor<PendingCheckin>(
            predicate: #Predicate { $0.attachedMomentId == nil },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        guard let candidates = try? context.fetch(fetch), !candidates.isEmpty else { return nil }

        // Pick nearest by time difference
        let now = Date()
        let best = candidates
            .map { ($0, DateUtils.secondsBetween($0.createdAt, now)) }
            .filter { $0.1 <= maxSeconds }
            .sorted { $0.1 < $1.1 }
            .first

        guard let (pending, _) = best, let score = pending.score else { return nil }

        pending.attachedMomentId = momentId
        try? context.save()
        return score
    }

    func run(image: UIImage, photoLocalIdentifier: String?, context: ModelContext, enableGestureScoring: Bool) async throws -> (Moment, PipelineOutput) {
        let moment = Moment(createdAt: .now)
        moment.photoLocalIdentifier = photoLocalIdentifier

        // 1) Scene
        let sceneRes = try await scene.classify(image: image)
        moment.sceneCategory = sceneRes.category
        moment.sceneConfidence = sceneRes.confidence
        moment.sceneLabelsJSON = JSONCodec.encode(sceneRes.labels)

        // 2) Score source priority:
        // (a) Pending notification score (if available)
        // (b) Gesture score (best effort)
        // (c) nil (user will set)
        var suggestedScore: Int? = attachPendingScore(context: context, momentId: moment.id)
        var scoreSource = suggestedScore == nil ? "manual" : "notif"

        if suggestedScore == nil, enableGestureScoring {
            if let handRes = try await hand.score(image: image) {
                suggestedScore = handRes.score
                scoreSource = "gesture"
            }
        }

        moment.score = suggestedScore
        moment.scoreSource = scoreSource

        // 3) Overlay render + persist
        let overlayImg = overlay.render(.init(baseImage: image, score: moment.score, category: moment.sceneCategory))
        let filename = "overlay_\(moment.id.uuidString).jpg"
        let path = try overlay.persistToDocuments(overlayImg, filename: filename)
        moment.overlayPath = path

        let output = PipelineOutput(
            suggestedScore: moment.score,
            scoreSource: scoreSource,
            category: moment.sceneCategory,
            sceneConfidence: moment.sceneConfidence,
            labelsJSON: moment.sceneLabelsJSON,
            overlayImage: overlayImg,
            overlayPath: path
        )
        return (moment, output)
    }
}
