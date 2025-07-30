import Foundation

@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var editingTransaction: Transaction? = nil
    @Published var showCreate = false

    let service: TransactionsService
    let direction: Direction   // хранит доходы/расходы
    
    init(service: TransactionsService, direction: Direction) {
        self.service = service
        self.direction = direction
    }
    
    func loadTransactions() async {
        isLoading = true; defer { isLoading = false }
        do {
            transactions = try await service.fetchTransactions(for: direction)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func addTransaction(_ tx: Transaction) async {
        isLoading = true; defer { isLoading = false }
        do {
            let newTx = try await service.addTransaction(tx)
            transactions.append(newTx)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func updateTransaction(_ tx: Transaction) async {
        isLoading = true; defer { isLoading = false }
        do {
            let result = try await service.updateTransaction(tx)
            if let idx = transactions.firstIndex(where: { $0.id == result.id }) {
                transactions[idx] = result
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func deleteTransaction(_ tx: Transaction) async {
        isLoading = true; defer { isLoading = false }
        do {
            try await service.deleteTransaction(tx)
            transactions.removeAll { $0.id == tx.id }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
