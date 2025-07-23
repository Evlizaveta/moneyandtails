import Foundation

final class CategoriesService {
    private let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    func fetchCategories() async throws -> [Category] {
        try await client.request(
            path: "/account",
            method: "GET",
            requestBody: Optional<EmptyRequest>.none // 👈 явно укажи generic RequestBody
            // queryItems: [URLQueryItem(name: "direction", value: direction.rawValue)]
        ) as [Category]                           // 👈 явно ResponseBody
    }
}
