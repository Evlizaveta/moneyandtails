import Foundation
import SwiftUI

struct TransactionsListView: View {
    let service = TransactionServiceMock()
    let direction: Direction

    @State private var transactions: [Transaction] = []
    @State private var showHistory = false
    
    private var todayBounds: (start: Date, end: Date) {
            let calendar = Calendar.current
            let now = Date()
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)!
            return (startOfDay, endOfDay)
        }

    var body: some View {
        NavigationStack {
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
                    }
                    .frame(height: 13)
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
                                HStack {
                                    Text(transaction.categoryId.name)
                                    Spacer()
                                    Text("\(NSDecimalNumber(decimal: transaction.amount).doubleValue, specifier: "%.0f") ₽")
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .padding(.top, -15)
                    .padding(.horizontal, -20)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(.systemBackground))
                            .shadow(color: Color(.separator).opacity(0.10), radius: 2, x: 0, y: 1)
                    )
                    .padding(.horizontal)
                }
                
                Button(action: { }) {
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
            .sheet(isPresented: $showHistory) {
                HistoryView(direction: direction)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadTransactions)
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
//
struct TransactionsListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsListView(direction: .income)
        TransactionsListView(direction: .outcome)
    }
} 
