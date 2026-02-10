import UIKit
@preconcurrency import Vision

struct HandScoreResult {
    let score: Int       // 1..5
    let confidence: Double
}

final class HandPoseScorer {
    func score(image: UIImage) async throws -> HandScoreResult? {
        guard let cg = image.cgImage else { return nil }
        let orientation = ImageOrientation.cgOrientation(from: image.imageOrientation)

        return try await withCheckedThrowingContinuation { cont in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let request = VNDetectHumanHandPoseRequest()
                    request.maximumHandCount = 1

                    let handler = VNImageRequestHandler(
                        cgImage: cg,
                        orientation: orientation,
                        options: [:]
                    )

                    try handler.perform([request])

                    guard let obs = request.results?.first else {
                        cont.resume(returning: nil)
                        return
                    }

                    let extended = Self.countExtendedFingers(observation: obs)
                    guard extended > 0 else {
                        cont.resume(returning: nil)
                        return
                    }

                    let score = min(max(extended, 1), 5)
                    cont.resume(returning: HandScoreResult(score: score, confidence: 0.7))
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }

    private static func countExtendedFingers(observation: VNHumanHandPoseObservation) -> Int {
        // Angle threshold: closer to 180° means straighter finger
        let thresholdRadians: Double = 2.6 // ~149°
        var count = 0

        func p(_ joint: VNHumanHandPoseObservation.JointName) -> CGPoint? {
            guard let point = try? observation.recognizedPoint(joint),
                  point.confidence > 0.3 else { return nil }
            return CGPoint(x: point.location.x, y: point.location.y)
        }

        func angle(a: CGPoint, b: CGPoint, c: CGPoint) -> Double {
            let ab = CGVector(dx: a.x - b.x, dy: a.y - b.y)
            let cb = CGVector(dx: c.x - b.x, dy: c.y - b.y)
            let dot = ab.dx * cb.dx + ab.dy * cb.dy
            let mag = sqrt(ab.dx * ab.dx + ab.dy * ab.dy) * sqrt(cb.dx * cb.dx + cb.dy * cb.dy)
            guard mag > 0 else { return 0 }
            let cosv = max(-1, min(1, dot / mag))
            return acos(cosv)
        }

        // Index
        if let mcp = p(.indexMCP), let pip = p(.indexPIP), let dip = p(.indexDIP),
           angle(a: mcp, b: pip, c: dip) > thresholdRadians { count += 1 }

        // Middle
        if let mcp = p(.middleMCP), let pip = p(.middlePIP), let dip = p(.middleDIP),
           angle(a: mcp, b: pip, c: dip) > thresholdRadians { count += 1 }

        // Ring
        if let mcp = p(.ringMCP), let pip = p(.ringPIP), let dip = p(.ringDIP),
           angle(a: mcp, b: pip, c: dip) > thresholdRadians { count += 1 }

        // Little
        if let mcp = p(.littleMCP), let pip = p(.littlePIP), let dip = p(.littleDIP),
           angle(a: mcp, b: pip, c: dip) > thresholdRadians { count += 1 }

        // Thumb (MP-IP-Tip)
        if let mp = p(.thumbMP), let ip = p(.thumbIP), let tip = p(.thumbTip),
           angle(a: mp, b: ip, c: tip) > thresholdRadians { count += 1 }

        return count
    }
}

