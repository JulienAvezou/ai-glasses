//
//  Moment.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import Foundation
import SwiftData

enum SceneCategory: String, Codable, CaseIterable, Identifiable {
    case gym, home, office, outdoors, restaurant, transit, store, nature, event, other
    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }
}

@Model
final class Moment {
    var id: UUID
    var createdAt: Date

    // Photos
    var photoLocalIdentifier: String?     // if loaded from PHAsset
    var overlayPath: String?              // stored in app Documents/

    // Score
    var score: Int?                       // 1...5 (nil = unknown)
    var scoreSource: String               // "gesture" | "notif" | "manual"

    // Scene
    var sceneCategoryRaw: String
    var sceneConfidence: Double
    var sceneLabelsJSON: String           // JSON array of {label, confidence}

    init(createdAt: Date = .now) {
        self.id = UUID()
        self.createdAt = createdAt
        self.score = nil
        self.scoreSource = "manual"
        self.sceneCategoryRaw = SceneCategory.other.rawValue
        self.sceneConfidence = 0
        self.sceneLabelsJSON = "[]"
    }

    var sceneCategory: SceneCategory {
        get { SceneCategory(rawValue: sceneCategoryRaw) ?? .other }
        set { sceneCategoryRaw = newValue.rawValue }
    }
}
