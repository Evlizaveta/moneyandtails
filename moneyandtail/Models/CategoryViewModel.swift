//
//  CategoriesViewModel.swift
//  moneyandtail
//
//  Created by Лиза on 05.07.2025.
//


import Foundation
import SwiftUI

struct CategoryViewModel: Identifiable {
    let id: Int
    let title: String
    let icon: Character
    let isIncome: Direction

    init(category: Category) {
        self.id = category.id
        self.title = category.name
        self.icon = category.emoji
        self.isIncome = category.direction
    }

    func toCategory() -> Category {
        return Category(
            id: id,
            name: title,
            emoji: icon,
            direction: isIncome
        )
    }
}
