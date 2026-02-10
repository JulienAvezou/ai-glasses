//
//  JSONCodec.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import Foundation

struct ClassifiedLabel: Codable, Identifiable {
    var id: String { label }
    let label: String
    let confidence: Double
}

enum JSONCodec {
    static func encode<T: Encodable>(_ value: T) -> String {
        do {
            let data = try JSONEncoder().encode(value)
            return String(data: data, encoding: .utf8) ?? "[]"
        } catch {
            return "[]"
        }
    }

    static func decode<T: Decodable>(_ type: T.Type, from json: String) -> T? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
