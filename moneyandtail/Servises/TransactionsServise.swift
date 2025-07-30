import Foundation

final class TransactionsService {
    private let client: NetworkClient
//    let storage: TransactionsStorage
//    let backupStorage: BackupStorage
    struct EmptyRequest: Encodable {}
    init(client: NetworkClient) {
        self.client = client
    }
    
    func fetchTransactions(for direction: Direction) async throws -> [Transaction] {
        try await client.request(
            path: "/transactions",
            method: "GET",
            requestBody: Optional<EmptyRequest>.none
        ) as [Transaction]
    }
    func addTransaction(_ tx: Transaction) async throws -> Transaction {
        try await client.request(
            path: "/transactions",
            method: "POST",
            requestBody: tx
        )
    }
    
    func updateTransaction(_ tx: Transaction) async throws -> Transaction {
        try await client.request(
            path: "/transactions/\(tx.id)",
            method: "PUT",
            requestBody: tx
        )
    }

    func deleteTransaction(_ tx: Transaction) async throws {
        _ = try await client.request(
            path: "/transactions/\(tx.id)",
            method: "DELETE",
            requestBody: Optional<EmptyRequest>.none
        ) as EmptyResponse
    }
}

struct EmptyRequest: Encodable {}
struct EmptyResponse: Decodable {}
