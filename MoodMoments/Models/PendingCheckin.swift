//
//  PendingCheckin.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import Foundation
import SwiftData

@Model
final class PendingCheckin {
    var id: UUID
    var createdAt: Date
    var score: Int?              // 1..5
    var attachedMomentId: UUID?  // once used

    init(createdAt: Date = .now, score: Int?) {
        self.id = UUID()
        self.createdAt = createdAt
        self.score = score
        self.attachedMomentId = nil
    }
}

