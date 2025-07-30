////
////  TransactionsFileCache.swift
////  moneyandtail
////
////  Created by Лиза on 13.06.2025.
////
//
//import Foundation
//
//final class TransactionsFileCache {
//    
//    class TransactionStore {
//        
//        private(set) var transactions: [Transaction] = []
//
//        func add(_ transaction: Transaction) {
//            if !transactions.contains(where: { $0.id == transaction.id }) {
//                transactions.append(transaction)
//            }
//        }
//
//        func remove(by id: Int) {
//            transactions.removeAll { $0.id == id }
//        }
//
//        func save(to filename: String) {
//            let array = transactions.map { $0.jsonObject }
//            guard JSONSerialization.isValidJSONObject(array),
//                  let data = try? JSONSerialization.data(withJSONObject: array, options: [.prettyPrinted]) else {
//                return
//            }
//            let url = getFileURL(for: filename)
//            do {
//                try data.write(to: url)
//            } catch {
//                print(error)
//            }
//        }
//
//        func load(from filename: String) {
//            let url = getFileURL(for: filename)
//            guard FileManager.default.fileExists(atPath: url.path),
//                  let data = try? Data(contentsOf: url),
//                  let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [Any] else {
//                return
//            }
//            let loaded = jsonArray.compactMap { Transaction.parse(jsonObject: $0) }
//            self.transactions = loaded
//        }
//
//        private func getFileURL(for filename: String) -> URL {
//            let name = filename.hasSuffix(".json") ? filename : filename + ".json"
//            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            return docs.appendingPathComponent(name)
//        }
//    }
//}
