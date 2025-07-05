import Foundation
import SwiftUI

struct HistoryView: View {
    let direction: Direction
    @Environment(\.presentationMode) var presentationMode
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var endDate: Date = Date()
    @State private var transactions: [Transaction] = []
    
    var body: some View {
        
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
<<<<<<< HEAD
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .imageScale(.large)
                                Text("Назад")
                            }
                            .foregroundColor(.purple)
                        }
                        Spacer()
                    }
                    .padding(.top, 24)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
=======
                            Image(systemName: "chevron.left")
                                .imageScale(.large)
                                .padding()
                        }
                        Spacer()
                    }
>>>>>>> corrected2
                                Text("Моя история")
                                    .font(.largeTitle).bold()
                                    .padding([.horizontal, .bottom])
                    .padding(.top, 8)
<<<<<<< HEAD
=======
                    .padding(.bottom, 0)
>>>>>>> corrected2
                    
                    List {
                        Section(header: EmptyView()) {
                            HStack {
                                Text("Начало")
<<<<<<< HEAD
                                    .padding(.horizontal, 8)
=======
>>>>>>> corrected2
                                Spacer()
                                DatePicker(
                                    "", selection: $startDate, in: ...endDate, displayedComponents: .date
                                )
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.accentColor.opacity(0.20))
                                )
                            }
                            
                            HStack {
                                Text("Конец")
<<<<<<< HEAD
                                    .padding(.horizontal, 8)
=======
>>>>>>> corrected2
                                Spacer()
                                DatePicker(
                                    "", selection: $endDate, in: startDate...Date(), displayedComponents: .date
                                )
                                .labelsHidden()
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.accentColor.opacity(0.19))
                                )
                            }
                            
                            HStack {
                                Text("Сумма")
<<<<<<< HEAD
                                    .padding(.horizontal, 8)
=======
>>>>>>> corrected2
                                Spacer()
                                Text("\(totalAmount, specifier: "%.0f") ₽")
                                    .font(.system(size: 18))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    .listStyle(.insetGrouped)
<<<<<<< HEAD
                            .frame(height: 200)
                            .padding(.horizontal, -12)
                            .padding(.top, -42)
=======
                            .frame(height: 170)
                            .padding(.horizontal, 0)
                            .padding(.top, 0)
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
>>>>>>> corrected2
                            .scrollContentBackground(.hidden)
                    
                    if transactions.isEmpty {
                        Spacer(minLength: 32)
                        Text("Нет транзакций")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.body)
                        Spacer()
                    } else {
                        List {
                            Section(header:
<<<<<<< HEAD
                                        Text("ОПЕРАЦИИ")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            )
                            {
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
                        .padding(.top, -25)
                        .padding(.horizontal, -27)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(.systemBackground))
                                .shadow(color: Color(.separator).opacity(0.10), radius: 2, x: 0, y: 1)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
=======
                                Text("ОПЕРАЦИИ")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 0)
                            ) {
                                ForEach(transactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                        }
                        .listRowInsets(EdgeInsets())
                        .listStyle(.plain)
                        .listRowBackground(Color.white)
                        .scrollContentBackground(.hidden)
                        //.background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal, 0)
                        .padding(.top, 0)
                        //.frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .padding([.horizontal])
                .padding(.bottom, 0)
>>>>>>> corrected2
            }
        }
        .onAppear(perform: loadTransactions)
        .onChange(of: startDate) { _ in
            if startDate > endDate { endDate = startDate }
            loadTransactions()
        }
        .onChange(of: endDate) { _ in
            if endDate < startDate { startDate = endDate }
            loadTransactions()
        }
    }
    
    private var totalAmount: Double {
        let sum = transactions.reduce(Decimal(0)) { $0 + $1.amount }
        return NSDecimalNumber(decimal: sum).doubleValue
    }
    private func monthYearString(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ru_RU")
        fmt.dateFormat = "LLLL yyyy"
        return fmt.string(from: date).capitalized
    }
    private func timeString(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.timeStyle = .short
        fmt.dateStyle = .none
        return fmt.string(from: date)
    }
    
    private var amountFormatter: NumberFormatter {
           let nf = NumberFormatter()
           nf.minimumFractionDigits = 2
           nf.maximumFractionDigits = 2
           return nf
       }
    
        private func loadTransactions() {
            let calendar = Calendar.current
            let start = calendar.startOfDay(for: startDate)
            let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
            Task {
                let loaded = await TransactionServiceMock.shared.getTransactions(from: start, to: end, direction: direction)
                await MainActor.run {
                    transactions = loaded
                }
            }
        }
    }

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HistoryView(direction: .income)
        }
        NavigationView {
            HistoryView(direction: .outcome)
        }
    }
}
