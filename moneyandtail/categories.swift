//
//  categories.swift
//  moneyandtail
//
//  Created by Лиза on 11.06.2025.
//

import Foundation

enum Direction: String, Codable {
    case income
    case outcome
}

struct Category: Identifiable, Codable {
    let id: String
    let name: String
    let emoji: Character
    let direction: Direction

    init(id: String, name: String, emoji: Character, direction: Direction) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.direction = direction
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, icon, isIncome
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .title)
        
        let iconString = try container.decode(String.self, forKey: .icon)
        guard let ch = iconString.first, iconString.count == 1 else {
            throw DecodingError.dataCorruptedError(
                forKey: .icon, in: container,
                debugDescription: "icon must be a single character")
        }
        emoji = ch
        
        let isIncomeBool = try container.decode(Bool.self, forKey: .isIncome)
        direction = isIncomeBool ? .income : .outcome
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .title)
        try container.encode(String(emoji), forKey: .icon)
        try container.encode(direction == .income, forKey: .isIncome)
    }
}
