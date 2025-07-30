//
//  Transaction.swift
//  moneyandtail
//
//  Created by Лиза on 13.06.2025.
//

import Foundation

struct Transaction: Identifiable, Decodable {
    
    struct Account: Decodable {
        let id: Int
    }
    
    struct Category: Decodable {
        let id: Int
    }
    
    let id: Int
    let account: Account
    let category: Category
    let amount: String
    let transactionDate: Date
    let comment: String?
//    let createdAt: Date
//    let updatedAt: Date
    
    var amountDouble: Double { Double(amount) ?? 0 }
    
    var amountDecimal: Decimal {
            Decimal(string: amount) ?? 0
        }
}
