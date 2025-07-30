//
//  BankAccounts.swift
//  moneyandtail
//
//  Created by Лиза on 13.06.2025.
//

import Foundation

struct Account: Identifiable, Codable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
//    let createdAt: Date
//    let updatedAt: Date
}
