import Foundation

final class AccountsService {
    private let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    func fetchMainAccount() async throws -> Account {
        try await client.request(
            path: "/account",
            method: "GET",
            requestBody: Optional<EmptyRequest>.none // 👈 явно укажи generic RequestBody
            // queryItems: [URLQueryItem(name: "direction", value: direction.rawValue)]
        ) as Account                           // 👈 явно ResponseBody
    }
    
    func fetchAllAccounts() async throws -> [Account] {
        try await client.request(
            path: "/account",
            method: "GET",
            requestBody: Optional<EmptyRequest>.none // 👈 явно укажи generic RequestBody
            // queryItems: [URLQueryItem(name: "direction", value: direction.rawValue)]
        ) as [Account]                           // 👈 явно ResponseBody
    }
//    func fetchMainAccount() async throws -> Account {
//        try await client.request(path: "/account/main")
//    }
    
//    func fetchAllAccounts() async throws -> [Account] {
//        try await client.request(path: "/accounts")
//    }
}
