//
//  Transaction.swift
//  moneyandtail
//
//  Created by Лиза on 13.06.2025.
//

import Foundation

struct Transaction: Identifiable, Codable {
    let id: Int
    let accountId: Account
    let categoryId: Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdDate: Date
    let updatedDate: Date

    private enum CodingKeys: String, CodingKey {
        case id, accountId, categoryId, amount, transactionDate, comment, createdDate, updatedDate
    }
}

extension Transaction {
    
    static func parse(jsonObject: Any) -> Transaction? {
        guard let data = try? JSONSerialization.data(withJSONObject: jsonObject) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(Transaction.self, from: data)
    }

    var jsonObject: Any {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(self),
              let json = try? JSONSerialization.jsonObject(with: data) else {
            return [:]
        }
        return json
    }
}
