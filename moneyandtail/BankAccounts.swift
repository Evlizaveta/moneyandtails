//
//  BankAccounts.swift
//  moneyandtail
//
//  Created by Лиза on 13.06.2025.
//

import Foundation

struct Account: Identifiable, Codable {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: String
    let createdDate: Date
    let updatedDate: Date

    private enum CodingKeys: String, CodingKey {
        case id, userId, name, balance, currency, createdDate, updatedDate
    }
}
