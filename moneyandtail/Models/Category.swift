//
//  categories.swift
//  moneyandtail
//
//  Created by Лиза on 11.06.2025.
//

import Foundation

struct Category: Identifiable, Codable {
    
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
    
    var direction: Direction {
        if isIncome { return .income }
        return .outcome
    }
}
