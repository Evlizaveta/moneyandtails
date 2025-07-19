import Foundation
import SwiftUI

struct TransactionsListView: View {
    let service = TransactionServiceMock()
    let direction: Direction
    let availableCategories: [Category]

    @State private var transactions: [Transaction] = []
    @State private var showHistory = false
    @State private var showEdit = false
    @State private var showCreate = false
    @State private var editingTransaction: Transaction?
    
    @EnvironmentObject var vm: TransactionsViewModel
    let mainAccount = Account(
        id: 6,
        userId: 7,
        name: "Основной счёт",
        balance: 10000,
        currency: "RUB",
        createdDate: Date(),
        updatedDate: Date()
    )
    var onSave: ((Transaction) -> Void)?
    var onDelete: ((Transaction) -> Void)?
    
    private var todayBounds: (start: Date, end: Date) {
            let calendar = Calendar.current
            let now = Date()
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)!
            return (startOfDay, endOfDay)
        }

    var body: some View {
        NavigationStack {
            if vm.isLoading {
                            ProgressView()
                        }
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
                        .font(.system(size: 34, weight: .bold))
                        .padding(.horizontal, 15)
                    
                    HStack {
                        Text("Всего")
                            .font(.system(size: 18))
                        Spacer()
                        Text("\(totalAmount, specifier: "%.0f") ₽")
                            .font(.system(size: 18))
                    }.frame(height: 13)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(.systemBackground))
                                .shadow(color: Color(.separator).opacity(0.10), radius: 2, x: 0, y: 1)
                        )
                        .padding(.horizontal)
                    List {
                        Section(header:
                                    Text("ОПЕРАЦИИ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        ) {
                            ForEach(transactions) { transaction in
                                Button {
                                    editingTransaction = transaction
//                                    showEdit = true
                                } label: {
                                    HStack {
                                        Text(transaction.categoryId.name)
                                        Spacer()
                                        Text("\(NSDecimalNumber(decimal: transaction.amount).doubleValue, specifier: "%.0f") ₽")
                                    }
                                    .padding(.vertical, 6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .padding(.top, -15)
                    .padding(.horizontal, -5)
                }
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
                
                .fullScreenCover(item: $editingTransaction) { transaction in
                    EditTransactionView(
                        mode: .edit,
                        initialTransaction: transaction,
                        availableCategories: availableCategories,
                        mainAccount: mainAccount,
                        onSave: { updated in
                                    if let i = transactions.firstIndex(where: { $0.id == updated.id }) {
                                        transactions[i] = updated
                                    }
                                    editingTransaction = nil
                                },
                                onDelete: { deleted in
                                    transactions.removeAll(where: { $0.id == deleted.id })
                                    editingTransaction = nil
                                }
                    )
                }

                .fullScreenCover(isPresented: $showCreate) {
                    EditTransactionView(
                        mode: .create,
                        initialTransaction: nil,
                        availableCategories: availableCategories,
                        mainAccount: mainAccount,
                        onSave: { newTx in
                                    transactions.append(newTx)
                                    showCreate = false
                                }
                    )
                }
                .background(Color(.systemGroupedBackground))
                
                
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button {
                            showHistory = true
                        } label: {
                            Image(systemName: "clock")
                                .tint(.purple)
                        }
                    }
                }
                .background(
                    NavigationLink(
                        destination: HistoryView(direction: direction, isActive: $showHistory),
                        isActive: $showHistory,
                        label: { EmptyView() }
                    )
                    .hidden()
                )
                .onAppear(perform: loadTransactions)
            }
            .alert(isPresented: Binding(get: { vm.error != nil }, set: { _ in vm.error = nil })) {
                       Alert(title: Text("Ошибка"), message: Text(vm.error ?? ""), dismissButton: .default(Text("OK")))
                   }
                   .task { await vm.loadTransactions() }
        }
    }
    
        
        private var totalAmount: Double {
            let sum = transactions.reduce(Decimal(0)) { $0 + $1.amount }
            return NSDecimalNumber(decimal: sum).doubleValue
        }
        
        func loadTransactions() {
            Task {
                let loaded = await service.getTransactions(
                    from: todayBounds.start,
                    to: todayBounds.end,
                    direction: direction
                )
                self.transactions = loaded
            }
        }
}

struct TransactionRow: View {
    let transaction: Transaction
    var body: some View {
        HStack {
            Text(transaction.categoryId.name)
            Spacer()
            Text("\(NSDecimalNumber(decimal: transaction.amount).doubleValue, specifier: "%.2f") ₽")
        }
        .font(.body)
        .padding(.horizontal)
    }
}
