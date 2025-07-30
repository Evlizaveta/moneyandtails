import Foundation
import SwiftUI

struct TransactionsListView: View {
    
    private let direction: Direction
    @State private var transactions: [Transaction] = [Transaction]()

    @State private var showHistory: Bool
    @State private var showCreate: Bool
    @State private var editingTransaction: Transaction?
    @State private var showAlert = false
    
    @EnvironmentObject var transactionsViewModel: TransactionsViewModel
    @EnvironmentObject var categoriesViewModel: CategoriesViewModel
    @EnvironmentObject var accountsViewModel: AccountsViewModel
    
    init(
        direction: Direction,
        showHistory: Bool = false,
        showCreate: Bool = false,
        editingTransaction: Transaction? = nil
    ) {
        self.direction = direction
        self.showHistory = showHistory
        self.showCreate = showCreate
        self.editingTransaction = editingTransaction
    }
    
    private var todayBounds: (start: Date, end: Date) {
            let calendar = Calendar.current
            let now = Date()
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)!
            return (startOfDay, endOfDay)
        }

    var body: some View {
        
        if transactionsViewModel.isLoading
            || accountsViewModel.isLoading
            || categoriesViewModel.isLoading
        { ProgressView() }
        
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    List {
                        Section(
                            header: Color.clear.frame(height: 0)
                        ) {
                            HStack {
                                Text("Всего")
                                    .font(.system(size: 18))
                                Spacer()
                                Text("\(totalAmount, specifier: "%.0f") ₽")
                                    .font(.system(size: 18))
                            }
                        }
                        Section(
                            header: Text("ОПЕРАЦИИ"),
                            footer: Color.clear.frame(height: 40)
                        ) {
                            ForEach(transactions) { transaction in
                                Button {
                                    editingTransaction = transaction
                                } label: {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color.accentColor.opacity(0.2))
                                                .frame(width: 25, height: 25)
                                            Text(categoriesViewModel.category(id: transaction.category.id)?.emoji ?? "")
                                                .font(.system(size: 14))
                                        }
                                        .padding(.trailing, 8)
                                        
                                        Text(categoriesViewModel.category(id: transaction.category.id)?.name ?? "")
                                        Spacer()
                                        Text("\(Int(transaction.amountDouble)) ₽")
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 2)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .listSectionSpacing(5)
                    .padding(.top, -20)
                }
                .background(Color(.systemGroupedBackground))
                
                Button(action: {
                    showCreate = true
                }) {
                    Circle()
                        .fill(Color("AccentColor"))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 25))
                                .foregroundColor(.white)
                        )
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
            }
            
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showHistory = true
                    } label: {
                        Image(systemName: "clock")
                            .tint(Color("ToolbarButton"))
                    }
                }
            }
            .navigationTitle(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
            .background(
                NavigationLink(
                    destination: HistoryView(direction: direction, isActive: $showHistory),
                    isActive: $showHistory,
                    label: { EmptyView() }
                )
                .hidden()
            )
        }
        .fullScreenCover(item: $editingTransaction) { transaction in
            EditTransactionView(
                mode: .edit(transaction),
                direction: direction
            )
        }

        .fullScreenCover(isPresented: $showCreate) {
            EditTransactionView(
                mode: .create,
                direction: direction
            )
        }
        .onReceive(transactionsViewModel.$transactions) { _ in
            updateTransactionsState()
        }
        .onReceive(transactionsViewModel.$isLoading) { _ in
            updateTransactionsState()
        }
        .onReceive(categoriesViewModel.$categories) { _ in
            updateTransactionsState()
        }
        .onReceive(accountsViewModel.$errorMessage) { message in
            if message != nil {
                showAlert  = true
            }
        }
        .onReceive(transactionsViewModel.$errorMessage) { message in
            if message != nil {
                showAlert  = true
            }
        }
        .onReceive(categoriesViewModel.$errorMessage) { message in
            if message != nil {
                showAlert  = true
            }
        }
        .alert("Не получилось обновить данные", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private func updateTransactionsState() {
        let today = Calendar.current.startOfDay(for: Date())
        transactions = transactionsViewModel.transactions.filter { transaction in
            let transactionDay = Calendar.current.startOfDay(for: transaction.transactionDate)
            return categoriesViewModel.category(id: transaction.category.id)?.direction == direction
//                && transactionDay == today
        }
    }
        
    private var totalAmount: Double {
        transactions.reduce(0.0) { $0 + $1.amountDouble }
    }
    
    private func loadTransactions() {
        Task {
            await transactionsViewModel.fetchUserTransactions()
        }
    }
}


//struct TransactionRow: View {
//    let transaction: Transaction
//    var body: some View {
//        HStack {
//            Text(transaction.category.id.name)
//            Spacer()
//            Text("\(NSDecimalNumber(decimal: transaction.amount).doubleValue, specifier: "%.2f") ₽")
//        }
//        .font(.body)
//        .padding(.horizontal)
//    }
//}
