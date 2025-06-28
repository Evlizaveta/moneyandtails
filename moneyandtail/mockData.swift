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

    static let mockCategoryGroceries = Category(
        id: 2,
        name: "Продукты",
        emoji: "🛒",
        direction: .outcome
    )
    static let mockCategorySalary = Category(
        id: 3,
        name: "Зарплата",
        emoji: "💼",
        direction: .income
    )
    static let mockCategoryCafe = Category(
        id: 4,
        name: "Кафе",
        emoji: "☕️",
        direction: .outcome
    )

    static let mockTransactions: [Transaction] = [
        Transaction(
            id: 5,
            accountId: mockAccount,
            categoryId: mockCategoryGroceries,
            amount: 1500,
            transactionDate: Date(),
            comment: "Купили продукты",
            createdDate: Date(),
            updatedDate: Date()
        ),
        Transaction(
            id: 6,
            accountId: mockAccount,
            categoryId: mockCategorySalary,
            amount: 50000,
            transactionDate: Date(),
            comment: "Выплата зарплаты",
            createdDate: Date(),
            updatedDate: Date()
        ),
        Transaction(
            id: 7,
            accountId: mockAccount,
            categoryId: mockCategoryCafe,
            amount: 450,
            transactionDate: Date(),
            comment: "Кофе с коллегами",
            createdDate: Date(),
            updatedDate: Date()
        ),
        Transaction(
            id: 8,
            accountId: mockAccount,
            categoryId: mockCategoryGroceries,
            amount: 1200,
            transactionDate: Date(),
            //transactionDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
            comment: "Супермаркет",
            createdDate: Date(),
            updatedDate: Date()
        )
    ]
}
