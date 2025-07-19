import Foundation
@MainActor

//@MainActor
//final class CategoriesViewModel: ObservableObject {
//    @Published var categories: [Category] = []
//    @Published var isLoading = false
//    @Published var error: String?
//    @Published var searchText: String = ""
//
//    init(categories: [Category]) {
//        self.categories = categories
//    }
//
//    var filteredCategories: [Category] {
//        searchText.isEmpty ? categories
//        : categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
//    }
//}


final class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText: String = ""

    let service: CategoriesService

    init(service: CategoriesService) {
        self.service = service
    }

    func loadCategories() async {
        isLoading = true; defer { isLoading = false }
        do {
            categories = try await service.fetchCategories()
        } catch {
            self.error = error.localizedDescription
        }
    }

    var filteredCategories: [Category] {
        searchText.isEmpty ? categories
        : categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}
