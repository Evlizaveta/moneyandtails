import Foundation

@MainActor
final class AccountsViewModel: ObservableObject {
    
    @Published var account: Account?
    @Published var errorMessage: String?
    var isLoading = false
    
    private let service: AccountsService
    
    init(service: AccountsService) {
        self.service = service
    }
    
    func reloadMainAccount() async {
        isLoading = true
        do {
            account = try await service.fetchAllAccounts().first
            isLoading = false
            errorMessage = nil
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func updateAccount(
        accountId: Int,
        name: String,
        balance: String,
        currency: String
    ) async -> Bool {
        do {
            try await service.updateAccount(
                accountId: accountId,
                name: name,
                balance: balance,
                currency: currency
            )
            await reloadMainAccount()
            return true
        } catch {
            return false
        }
    }
    
    func formatBalance(_ balance: String) -> String {
        guard let value = Double(balance) else { return balance }
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        } else {
            return String(format: "%.2f", value)
        }
    }
}
