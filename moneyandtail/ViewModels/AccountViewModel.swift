import Foundation

@MainActor
final class AccountsViewModel: ObservableObject {
    @Published var mainAccount: Account?
    @Published var accounts: [Account] = []
    @Published var isLoading = false
    @Published var error: String?

    let service: AccountsService

    init(service: AccountsService) {
        self.service = service
    }

    func loadMainAccount() async {
        isLoading = true; defer { isLoading = false }
        do {
            mainAccount = try await service.fetchMainAccount()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadAllAccounts() async {
        isLoading = true; defer { isLoading = false }
        do {
            accounts = try await service.fetchAllAccounts()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
