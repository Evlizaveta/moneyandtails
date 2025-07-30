import Foundation
import SwiftUI

struct HistoryView: View {
    
    let direction: Direction
    
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var endDate: Date = Date()
    @State private var transactions: [Transaction] = []
    @State private var showAnalyze = false
    
    @EnvironmentObject var transactionsVM: TransactionsViewModel
    @EnvironmentObject var categoriesVM: CategoriesViewModel
    
    @Binding var isActive: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section {
                        startDateView.padding(.leading, 8)
                        endDateView.padding(.leading, 8)
                        totalAmountView.padding(.leading, 8)
                    }
                    .listRowInsets(
                        EdgeInsets()
                    )
                    
                    if transactions.isEmpty {
                        Text("Нет транзакций")
                            .foregroundColor(.secondary)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .center
                            )
                            .font(.body)
                        Spacer()
                    } else {
                        Section(header: Text("ОПЕРАЦИИ").font(.caption)) {
                            ForEach(transactions) { transaction in
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.accentColor.opacity(0.2))
                                            .frame(width: 25, height: 25)
                                        Text(categoriesVM.category(id: transaction.category.id)?.emoji ?? "")
                                            .font(.system(size: 14))
                                    }
                                    .padding(.trailing, 8)
                                    Text(categoriesVM.category(id: transaction.category.id)?.name ?? "")
                                    Spacer()
                                    Text("\(Int(transaction.amountDouble)) ₽")
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .padding(.trailing, 16)
                                }
                                .frame(height: 55)
                                .padding(.leading, 16)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isActive = false
                    } label: {
                        Image(systemName: "chevron.left")
                        Text("Назад")
                    }
                    .tint(Color("ToolbarButton"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAnalyze = true
                    } label: {
                        Image(systemName: "doc")
                            .imageScale(.large)
                            .foregroundColor(Color("ToolbarButton"))
                    }
                }
            }
            .navigationTitle("Моя история")
            .navigationBarBackButtonHidden(true)
            .background(
                NavigationLink(
                    destination: AnalyzeViewControllerRepresentable(
                        transactions: transactions,
                        categories: categoriesVM.categories,
                        direction: direction),
                    isActive: $showAnalyze,
                    label: { EmptyView() }
                ).hidden()
            )
            .onAppear(perform: loadTransactions)
            .onChange(of: startDate) { _ in
                if startDate > endDate {
                    endDate = startDate
                }
                loadTransactions()
            }
            .onChange(of: endDate) { _ in
                if endDate < startDate {
                    startDate = endDate
                }
                loadTransactions()
            }
        }
    }

    var startDateView: some View {
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
    }
    
    var endDateView: some View {
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
    }
    
    var totalAmountView: some View {
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
    
    private var totalAmount: Double {
        transactions.reduce(0.0) { $0 + $1.amountDouble }
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
        transactions = transactionsVM.transactions.filter({ transaction in
            start < transaction.transactionDate
                && transaction.transactionDate < end
                && categoriesVM.category(id: transaction.category.id)?.direction == direction
        })
    }
}

struct AnalyzeViewControllerRepresentable: UIViewControllerRepresentable {
    
    let transactions: [Transaction]
    let categories: [Category]
    let direction: Direction
    
    func makeUIViewController(context: Context) -> AnalyzeViewController {
        AnalyzeViewController(transactions: transactions, categories: categories, direction: direction)
    }
    func updateUIViewController(_ uiViewController: AnalyzeViewController, context: Context) {}
}
//
//struct HistoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            HistoryView(direction: .income, isActive: .constant(true))
//        }
//        NavigationView {
//            HistoryView(direction: .outcome, isActive: .constant(true))
//        }
//    }
//}
