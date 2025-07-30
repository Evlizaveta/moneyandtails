//
//  TransationsMocks.swift
//  moneyandtail
//
//  Created by Лиза on 13.06.2025.
//
//
//import Foundation
//
//final class TransactionServiceMock {
//    static let shared = TransactionServiceMock()
//    private var transactions: [Transaction] = MockData.mockTransactions
//    
//    func getTransactions(from startDate: Date, to endDate: Date, direction: Direction) async -> [Transaction] {
//        return transactions.filter { $0.transactionDate >= startDate && $0.transactionDate <= endDate && $0.categoryId.direction == direction}
//    }
//    
//    func createTransaction(_ transaction: Transaction) async {
//        transactions.append(transaction)
//    }
//    
//    func updateTransaction(_ transaction: Transaction) async {
//        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
//            transactions[index] = transaction
//        }
//    }
//    
//    func deleteTransaction(by id: Int) async {
//        transactions.removeAll { $0.id == id }
//    }
//}
