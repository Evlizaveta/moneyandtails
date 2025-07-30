import Foundation

final class CategoriesService {
    
    private let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    func fetchCategories() async throws -> [Category] {
        try await client.request(
            path: "/categories",
            method: .get
        ) as [Category]
    }
}

