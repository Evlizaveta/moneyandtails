import Foundation

final class TransactionsService {
    private let client: NetworkClient

    init(client: NetworkClient) {
        self.client = client
    }
    
    func fetchAllTransactions(
        accountId: Int,
        startDate: Date = Date(timeIntervalSince1970: 0),
        endDate: Date = Date()
    ) async throws -> [Transaction] {
        try await client.request(
            path: "/transactions/account/\(accountId)/period",
            method: .get,
            queryItems: [
                .init(name: "startDate", value: convertDate(startDate)),
                .init(name: "endDate", value: convertDate(endDate)),
            ]
        )
    }
    
    func addTransaction(
        accountId: Int,
        categoryId: Int,
        amount: String,
        transactionDate: Date,
        comment: String?
    ) async throws {
        let _: EmptyResponse = try await client.request(
            path: "/transactions",
            method: .post,
            requestBody: AddOrEditTransactionParams(
                accountId: accountId,
                categoryId: categoryId,
                amount: amount,
                transactionDate: transactionDate,
                comment: comment
            )
        )
    }
    
    func editTransaction(
        transactionId: Int,
        accountId: Int,
        categoryId: Int,
        amount: String,
        transactionDate: Date,
        comment: String?
    ) async throws {
        let _: EmptyResponse = try await client.request(
            path: "/transactions/\(transactionId)",
            method: .put,
            requestBody: AddOrEditTransactionParams(
                accountId: accountId,
                categoryId: categoryId,
                amount: amount,
                transactionDate: transactionDate,
                comment: comment
            )
        )
    }
    
    func deleteTransaction(_ transactionId: Int) async throws {
        let _: EmptyResponse = try await client.request(
            path: "/transactions/\(transactionId)",
            method: .delete
        )
    }
    
    private func convertDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}

private struct AddOrEditTransactionParams: Encodable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: Date
    let comment: String?
}

private struct EmptyResponse: Decodable {}
