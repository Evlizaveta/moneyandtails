import Combine
import Foundation

@MainActor
final class TransactionsViewModel: ObservableObject {
    
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service: TransactionsService
    private let accountsViewModel: AccountsViewModel
    
    private var subscriptions: [AnyCancellable] = []
    
    deinit {
        subscriptions.forEach({ $0.cancel() })
        subscriptions.removeAll()
    }

    init(service: TransactionsService, accountsViewModel: AccountsViewModel) {
        self.service = service
        self.accountsViewModel = accountsViewModel
        
        let accountSubs = accountsViewModel.$account.sink { [weak self] _ in
            Task {
                await self?.fetchUserTransactions()
            }
        }
        subscriptions.append(accountSubs)
    }
    
    func fetchUserTransactions() async {
        guard let id = accountsViewModel.account?.id else { return }
        isLoading = true
        do {
            let transactions = try await service.fetchAllTransactions(accountId: id)
            self.transactions = transactions ?? []
            isLoading = false
            errorMessage = nil
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteTransaction(_ transactionId: Int) async {
        try? await service.deleteTransaction(transactionId)
        await fetchUserTransactions()
    }
    
    func addTransaction(
        accountId: Int,
        categoryId: Int,
        amount: String,
        transactionDate: Date,
        comment: String?
    ) async -> Bool {
        do {
            try await service.addTransaction(
                accountId: accountId,
                categoryId: categoryId,
                amount: amount,
                transactionDate: transactionDate,
                comment: comment
            )
            await fetchUserTransactions()
            return true
        } catch {
            return false
        }
    }
    
    func editTransaction(
        transactionId: Int,
        accountId: Int,
        categoryId: Int,
        amount: String,
        transactionDate: Date,
        comment: String?
    ) async -> Bool {
        do {
            try await service.editTransaction(
                transactionId: transactionId,
                accountId: accountId,
                categoryId: categoryId,
                amount: amount,
                transactionDate: transactionDate,
                comment: comment
            )
            await fetchUserTransactions()
            return true
        } catch {
            return false
        }
    }
}
