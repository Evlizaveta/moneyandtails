import Foundation

final class AccountsService {
    
    private let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    func updateAccount(
        accountId: Int,
        name: String,
        balance: String,
        currency: String
    ) async throws {
        let body = UpdateAccountRequest(name: name, balance: balance, currency: currency)
        let _: EmptyResponse = try await client.request(
            path: "/accounts/\(accountId)",
            method: .put,
            requestBody: body
        )
    }
    
    func fetchAllAccounts() async throws -> [Account] {
        try await client.request(
            path: "/accounts",
            method: .get
        ) as [Account]
    }
}

//struct Account: Identifiable, Codable {
//    let id: Int
//    let name: String
//    let balance: String
//    let currency: String

private struct EmptyResponse: Decodable {}

struct UpdateAccountRequest: Encodable {
    let name: String
    let balance: String
    let currency: String
}
