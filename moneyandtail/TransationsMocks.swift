//
//  TransationsMocks.swift
//  moneyandtail
//
//  Created by Лиза on 13.06.2025.
//

import Foundation

final class TransactionServiceMock {
    private var transactions: [Transaction] = MockData.mockTransactions
    
    func getTransactions(from startDate: Date, to endDate: Date) async -> [Transaction] {
        return transactions.filter { $0.date >= startDate && $0.date <= endDate }
    }
    
    func createTransaction(_ transaction: Transaction) async {
        transactions.append(transaction)
    }
    
    func updateTransaction(_ transaction: Transaction) async {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
        }
    }
    
    func deleteTransaction(by id: String) async {
        transactions.removeAll { $0.id == id }
    }
}
