import Foundation
import Combine

@MainActor
final class CategoriesViewModel: ObservableObject {
    
    @Published var categories: [Category] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let service: CategoriesService
    private let accountsVM: AccountsViewModel
    
    private var subscriptions: [AnyCancellable] = []
    
    deinit {
        subscriptions.forEach({ $0.cancel() })
        subscriptions.removeAll()
    }

    init(
        service: CategoriesService,
        accountsVM: AccountsViewModel
    ) {
        self.service = service
        self.accountsVM = accountsVM
        
        let accountSubs = accountsVM.$account.sink { [weak self] _ in
            Task {
                await self?.fetchCategories()
            }
        }
        subscriptions.append(accountSubs)
    }

    func fetchCategories() async {
        isLoading = true
        do {
            categories = try await service.fetchCategories()
            isLoading = false
            errorMessage = nil
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func category(id: Int) -> Category? {
        categories.first { $0.id == id }
    }
}
