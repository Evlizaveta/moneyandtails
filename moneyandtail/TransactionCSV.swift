//
//  TransactionCSV.swift
//  moneyandtail
//
//  Created by Лиза on 13.06.2025.
//

import Foundation

extension Transaction {
    static func parseCSV(csvLine: String) -> Transaction? {
        let components = csvLine.components(separatedBy: ",")

        guard components.count >= 8 else { return nil }

        let id = Int(components[0])!
        let account = Account (
            id: Int(components[1])!,
            userId: 7,
            name: components[2],
            balance: 0,
            currency: "RUB",
            createdDate: Date(),
            updatedDate: Date()
        )
        let category = Category(
            id: Int(components[3])!,
            name: components[4],
            emoji: "🛒",
            direction: .outcome
        )

        guard let amount = Decimal(string: components[5]) else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: components[6]) else { return nil }

        let comment = components[7]

        return Transaction(
            id: id,
            accountId: account,
            categoryId: category,
            amount: amount,
            transactionDate: date,
            comment: comment,
            createdDate: Date(),
            updatedDate: Date()
        )
    }
}
