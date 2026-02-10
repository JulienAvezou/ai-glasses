//
//  DateUtils.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import Foundation

enum DateUtils {
    static func secondsBetween(_ a: Date, _ b: Date) -> TimeInterval {
        abs(a.timeIntervalSince(b))
    }
}
