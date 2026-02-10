//
//  ImageOrientation.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import UIKit
import ImageIO

enum ImageOrientation {
    static func cgOrientation(from ui: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch ui {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}

