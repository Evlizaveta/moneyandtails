////
////  mockData.swift
////  moneyandtail
////
////  Created by Лиза on 14.06.2025.
////
//import Foundation
//
//enum MockData {
//    static let mockAccount = Account(
//        id: 6,
//        userId: 7,
//        name: "Основной счёт",
//        balance: 10000,
//        currency: "RUB",
//        createdAt: Date(),
//        updatedAt: Date()
//    )
//    static let mockCategories: [Category] = [
//        Category(
//        id: 2,
//        name: "Продукты",
//        emoji: "🛒",
//        direction: .outcome
//    ),
//    Category(
//        id: 3,
//        name: "Зарплата",
//        emoji: "💼",
//        direction: .income
//    ),
//    Category(
//        id: 4,
//        name: "Кафе",
//        emoji: "☕️",
//        direction: .outcome
//    )
//        ]
//
//    static let mockTransactions: [Transaction] = [
//        Transaction(
//            id: 5,
//            accountId: mockAccount,
//            categoryId: mockCategories[0],
//            amount: 1500,
//            transactionDate: Date(),
//            comment: "Купили продукты",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        Transaction(
//            id: 6,
//            accountId: mockAccount,
//            categoryId: mockCategories[1],
//            amount: 50000,
//            transactionDate: Date(),
//            comment: "Выплата зарплаты",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        Transaction(
//            id: 7,
//            accountId: mockAccount,
//            categoryId: mockCategories[2],
//            amount: 450,
//            transactionDate: Date(),
//            comment: "Кофе с коллегами",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        Transaction(
//            id: 8,
//            accountId: mockAccount,
//            categoryId: mockCategories[0],
//            amount: 1200,
//            transactionDate: Date(),
//            //transactionDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
//            comment: "Супермаркет",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        Transaction(
//            id: 8,
//            accountId: mockAccount,
//            categoryId: mockCategories[1],
//            amount: 50000,
//            transactionDate: Date(),
//            comment: "Зарплата",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        Transaction(
//            id: 9,
//            accountId: mockAccount,
//            categoryId: mockCategories[2],
//            amount: 450,
//            transactionDate: Date(),
//            comment: "Кофе",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        Transaction(
//            id: 10,
//            accountId: mockAccount,
//            categoryId: mockCategories[0],
//            amount: 1200,
//            transactionDate: Date(),
//            comment: "Супермаркет",
//            createdAt: Date(),
//            updatedAt: Date()
//        )
//    ]
//}
