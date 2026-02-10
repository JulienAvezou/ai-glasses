import UIKit
@preconcurrency import Vision

struct SceneResult {
    let category: SceneCategory
    let confidence: Double
    let labels: [ClassifiedLabel]
}

final class SceneClassifier {
    func classify(image: UIImage) async throws -> SceneResult {
        guard let cg = image.cgImage else {
            return SceneResult(category: .other, confidence: 0, labels: [])
        }

        let orientation = ImageOrientation.cgOrientation(from: image.imageOrientation)

        return try await withCheckedThrowingContinuation { cont in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let request = VNClassifyImageRequest()
                    let handler = VNImageRequestHandler(
                        cgImage: cg,
                        orientation: orientation,
                        options: [:]
                    )

                    try handler.perform([request])

                    let obs: [VNClassificationObservation] = request.results ?? []
                    let top = Array(obs.prefix(10)).map {
                        ClassifiedLabel(label: $0.identifier, confidence: Double($0.confidence))
                    }

                    let mapped = Self.mapToCategory(labels: top)
                    cont.resume(returning: SceneResult(
                        category: mapped.category,
                        confidence: mapped.confidence,
                        labels: top
                    ))
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Pure helpers (static)
    private static func mapToCategory(labels: [ClassifiedLabel]) -> (category: SceneCategory, confidence: Double) {
        let joined = labels.map { $0.label.lowercased() }

        func containsAny(_ keys: [String]) -> Bool {
            for k in keys {
                if joined.contains(where: { $0.contains(k) }) { return true }
            }
            return false
        }

        if containsAny(["gym", "fitness", "treadmill", "weight", "workout"]) { return (.gym, confidenceHint(labels)) }
        if containsAny(["home", "living room", "bedroom", "kitchen", "house"]) { return (.home, confidenceHint(labels)) }
        if containsAny(["office", "desk", "computer", "workstation", "conference room"]) { return (.office, confidenceHint(labels)) }
        if containsAny(["restaurant", "cafe", "bar", "dining"]) { return (.restaurant, confidenceHint(labels)) }
        if containsAny(["train", "subway", "metro", "bus", "station", "platform", "airport"]) { return (.transit, confidenceHint(labels)) }
        if containsAny(["store", "shop", "supermarket", "grocery", "mall"]) { return (.store, confidenceHint(labels)) }
        if containsAny(["forest", "mountain", "beach", "park", "lake", "nature"]) { return (.nature, confidenceHint(labels)) }
        if containsAny(["stadium", "concert", "stage", "crowd", "event"]) { return (.event, confidenceHint(labels)) }
        if containsAny(["street", "outdoor", "sky", "sidewalk", "road"]) { return (.outdoors, confidenceHint(labels)) }

        return (.other, confidenceHint(labels))
    }

    private static func confidenceHint(_ labels: [ClassifiedLabel]) -> Double {
        labels.first?.confidence ?? 0
    }
}

