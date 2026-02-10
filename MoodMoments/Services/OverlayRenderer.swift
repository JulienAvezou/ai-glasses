//
//  OverlayRenderer.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import UIKit

struct OverlayInput {
    let baseImage: UIImage
    let score: Int?
    let category: SceneCategory
}

final class OverlayRenderer {
    func render(_ input: OverlayInput) -> UIImage {
        let img = input.baseImage
        let renderer = UIGraphicsImageRenderer(size: img.size)

        return renderer.image { ctx in
            img.draw(in: CGRect(origin: .zero, size: img.size))

            let badge = "\(input.category.displayName) · \(input.score.map { "\($0)/5" } ?? "—")"
            drawBadge(text: badge, in: ctx.cgContext, canvasSize: img.size)
        }
    }

    private func drawBadge(text: String, in context: CGContext, canvasSize: CGSize) {
        let padding: CGFloat = 18
        let badgeHeight: CGFloat = 70
        let maxWidth = canvasSize.width - 2 * padding
        let badgeRect = CGRect(x: padding, y: padding, width: maxWidth, height: badgeHeight)

        context.setFillColor(UIColor.black.withAlphaComponent(0.65).cgColor)
        let path = UIBezierPath(roundedRect: badgeRect, cornerRadius: 18)
        context.addPath(path.cgPath)
        context.fillPath()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 34, weight: .semibold),
            .foregroundColor: UIColor.white
        ]
        let attributed = NSAttributedString(string: text, attributes: attrs)
        let textRect = badgeRect.insetBy(dx: 20, dy: 12)
        attributed.draw(in: textRect)
    }

    func persistToDocuments(_ image: UIImage, filename: String) throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.88) else {
            throw NSError(domain: "OverlayRenderer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JPEG"])
        }
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = dir.appendingPathComponent(filename)
        try data.write(to: url, options: .atomic)
        return url.path
    }
}
