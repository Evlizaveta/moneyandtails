//
//  mockData.swift
//  moneyandtail
//
//  Created by Лиза on 14.06.2025.
//

import Foundation

enum MockData {
    static let mockAccount = Account(
        id: 6,
        userId: 7,
        name: "Основной счёт",
        balance: 10000,
        currency: "RUB",
        createdDate: Date(),
        updatedDate: Date()
    )

    static let mockCategory = Category(
        id: 2,
        name: "Продукты",
        emoji: "🛒",
        direction: .outcome
    )

    static let mockTransactions: [Transaction] = [
        Transaction(
            id: 5,
            accountId: mockAccount,
            categoryId: mockCategory,
            amount: 1500,
            transactionDate: Date(),
            comment: "Продукты",
            createdDate: Date(),
            updatedDate: Date()
        )
    ]
}
