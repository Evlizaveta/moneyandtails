import Foundation
import SwiftUI

struct HistoryView: View {
    let direction: Direction
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var endDate: Date = Date()
    @State private var transactions: [Transaction] = []
    @State private var showAnalyze = false
    
    @EnvironmentObject var transactionsVM: TransactionsViewModel
    
    @Binding var isActive: Bool

    var body: some View {
            NavigationView {
                ZStack {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer().frame(height: 12)
                        
                        HStack {
                            Button(action: {
                                isActive = false
                            }) {
                                HStack(spacing: 2) {
                                    Image(systemName: "chevron.left")
                                        .imageScale(.large)
                                Text("Назад")
                            }
                            .foregroundColor(.purple)
                        }
                        Spacer()
                            
                            Button(action: {
                                                showAnalyze = true
                                            }) {
                                                Image(systemName: "doc.on.doc")
                                                    .imageScale(.large)
                                                    .foregroundColor(.purple)
                                            }
                                        }
                    .padding(.horizontal)
                    
                    Text("Моя история")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    Spacer()
                    
                    
                    List {
                        Section(header: EmptyView()) {
                            HStack {
                                Text("Начало")
                                    .padding(.horizontal, 8)
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
                                    .padding(.horizontal, 8)
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
                                    .padding(.horizontal, 8)
                                Spacer()
                                Text("\(totalAmount, specifier: "%.0f") ₽")
                                    .font(.system(size: 18))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        
                        if transactions.isEmpty {
                            Text("Нет транзакций")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(.body)
                            Spacer()
                        } else {
                            Section(header:
                                        Text("ОПЕРАЦИИ")
                                .font(.caption)
                            )
                            {
                                ForEach(transactions) { transaction in
                                    HStack {
                                        Text(transaction.categoryId.name)
                                        Spacer()
                                        Text("\(NSDecimalNumber(decimal: transaction.amount).doubleValue, specifier: "%.0f") ₽")
                                    }
                                    .frame(height: 58)
                                    .padding(.horizontal, 8)
                                }
                            }
                            .listRowInsets(EdgeInsets())
                        }
                    }
                    .listStyle(.insetGrouped)
                    .padding(.top, -45)
                    .padding(.horizontal, -27)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGroupedBackground))
                    .padding(.horizontal)
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
            .navigationBarBackButtonHidden(true)
            .background(
                        NavigationLink(
                            destination: AnalyzeViewControllerRepresentable(),
                            isActive: $showAnalyze,
                            label: { EmptyView() }
                        ).hidden()
                        )
    }
    
//
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

import SwiftUI

struct AnalyzeViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AnalyzeViewController {
        AnalyzeViewController()
    }
    func updateUIViewController(_ uiViewController: AnalyzeViewController, context: Context) {}
}
//
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HistoryView(direction: .income, isActive: .constant(true))
        }
        NavigationView {
            HistoryView(direction: .outcome, isActive: .constant(true))
        }
    }
}
