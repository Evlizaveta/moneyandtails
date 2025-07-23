import SwiftUI
import Combine

enum EditMode {
    case create, edit
}

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var transactionsVM: TransactionsViewModel
    
    let mode: EditMode
    let initialTransaction: Transaction?
    let availableCategories: [Category]
    let mainAccount: Account
    var onSave: ((Transaction) -> Void)?
    var onDelete: ((Transaction) -> Void)?

    @State private var selectedCategory: Category?
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var comment: String = ""
    @State private var dateOnly: Date = Date()
    @State private var timeOnly: Date = Date()

    @State private var showCategoryPicker = false
    @State private var showAlert = false
    @State private var alertText = ""

    let decimalSeparator: String = Locale.current.decimalSeparator ?? "."

    var body: some View {
        NavigationView {
            Form {
                Button(action: { showCategoryPicker = true }) {
                    HStack {
                        Text("Статья")
                            .foregroundColor(.primary)
                        Spacer()
                        if let category = selectedCategory {
                            Text(category.name).foregroundColor(.primary)
                        } else {
                            Text("Выберите статью")
                                .foregroundColor(.secondary)
                        }
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .actionSheet(isPresented: $showCategoryPicker) {
                    ActionSheet(title: Text("Выберите статью"), buttons:
                        availableCategories.map { c in
                            .default(Text(c.name), action: { selectedCategory = c })
                        } + [.cancel()]
                    )
                }

                HStack {
                    Text("Сумма")
                    Spacer()
                    TextField("0\(decimalSeparator)00", text: bindingAmount)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .onReceive(Just(amount)) { newValue in
                            self.amount = filterAmountString(newValue)
                        }
                        .frame(width: 120)
                }
                DatePicker("Дата", selection: $dateOnly, in: ...Date(), displayedComponents: .date)
                DatePicker("Время", selection: $timeOnly, displayedComponents: .hourAndMinute)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.accentColor.opacity(0.19))
                    )

                HStack {
                    Text("Комментарий")
                    Spacer()
                    ZStack(alignment: .leading) {
                        if comment.isEmpty {
                            Text("Комментарий")
                                .foregroundColor(.gray)
                        }
                        TextField("", text: $comment)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                if mode == .edit {
                    Section {
                        Button(role: .destructive) {
                            if let tx = initialTransaction {
                                onDelete?(tx)
                            }
                            dismiss()
                        } label: {
                            Text("Удалить операцию")
                        }
                    }
                }
            }
            .navigationTitle(mode == .edit ? "Редактирование" : "Создание")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(mode == .edit ? "Сохранить" : "Создать") {
                        saveAction()
                    }
                    .font(.headline)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(.secondary)
                }
            }
            .alert(alertText, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            .onAppear { fillIfEditing() }
        }
        .navigationViewStyle(.stack)
    }
    var bindingAmount: Binding<String> {
        Binding(
            get: { amount },
            set: { newValue in
                let filtered = filterAmountString(newValue)
                if filtered.filter({ $0 == Character(decimalSeparator) }).count > 1 {
                    return
                }
                amount = filtered
            }
        )
    }

    func filterAmountString(_ s: String) -> String {
        let allowedChars = CharacterSet(charactersIn: "0123456789\(decimalSeparator)")
        return String(s.filter { String($0).rangeOfCharacter(from: allowedChars) != nil })
    }
    
    func fillIfEditing() {
        guard mode == .edit, let tx = initialTransaction else { return }
        selectedCategory = tx.categoryId
        amount = NSDecimalNumber(decimal: tx.amount).stringValue
        date = tx.transactionDate
        comment = tx.comment ?? ""
        dateOnly = Calendar.current.startOfDay(for: tx.transactionDate)
        let components = Calendar.current.dateComponents([.hour, .minute], from: tx.transactionDate)
        timeOnly = Calendar.current.date(from: components) ?? Date()
    }
    
    func saveAction() {
        guard let category = selectedCategory, !amount.isEmpty,
              let value = Decimal(string: amount.replacingOccurrences(of: decimalSeparator == "," ? "." : ",", with: decimalSeparator)) else {
            alertText = "Пожалуйста, заполните все поля и убедитесь, что сумма указана правильно."
            showAlert = true
            return
        }
        let tx = Transaction(
            id: initialTransaction?.id ?? Int.random(in: 10_000...99_999),
            accountId: mainAccount,
            categoryId: category,
            amount: value,
            transactionDate: combineDateAndTime(date: dateOnly, time: timeOnly), // Собираем!
            comment: comment.isEmpty ? nil : comment,
            createdDate: initialTransaction?.createdDate ?? Date(),
            updatedDate: Date()
        )
        onSave?(tx)
        dismiss()
    }
    func combineDateAndTime(date: Date, time: Date) -> Date {
        let cal = Calendar.current
        var dateComp = cal.dateComponents([.year, .month, .day], from: date)
        let timeComp = cal.dateComponents([.hour, .minute, .second], from: time)
        dateComp.hour = timeComp.hour
        dateComp.minute = timeComp.minute
        dateComp.second = timeComp.second
        return cal.date(from: dateComp) ?? date
    }

}
