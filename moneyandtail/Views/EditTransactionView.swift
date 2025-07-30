import SwiftUI
import Combine
import Foundation

enum EditMode {
    case create
    case edit(Transaction)
    
    fileprivate var trailingToolbarButtonTitle: String {
        switch self {
        case .create:
            return "Создать"
        case .edit:
            return "Сохранить"
        }
    }
}

struct EditTransactionView: View {
    
    @EnvironmentObject var transactionsViewModel: TransactionsViewModel
    @EnvironmentObject var categoriesViewModel: CategoriesViewModel
    @EnvironmentObject var accountsViewModel: AccountsViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    private let mode: EditMode
    private let direction: Direction
    private let navigationTitle: String
    
    @State private var selectedCategory: Category?
    @State private var amount: String
    @State private var date: Date
    @State private var comment: String
    
    @State private var showCategoryPicker = false
    @State private var showAlert = false
    @State private var alertText = ""
    
    private var availableCategories: [Category] {
        categoriesViewModel.categories.filter({ $0.direction == direction })
    }
    private lazy var decimalSeparator: String = { Locale.current.decimalSeparator ?? "." }()
    
    init(
        mode: EditMode,
        direction: Direction
    ) {
        self.mode = mode
        self.direction = direction
        switch mode {
        case .create:
            selectedCategory = nil
            amount = ""
            date = Date()
            comment = ""
        case .edit(let transaction):
            self.selectedCategory = nil
            self.amount = transaction.amount
            self.date = transaction.transactionDate
            self.comment = transaction.comment ?? ""
        }
        switch direction {
        case .income:
            navigationTitle = "Мои Доходы"
        case .outcome:
            navigationTitle = "Мои Расходы"
        }
    }
    
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
                    ActionSheet(
                        title: Text("Выберите статью"),
                        buttons: availableCategories.map { category in
                            .default(
                                Text(category.name),
                                action: {
                                    selectedCategory = category
                                }
                            )
                        } + [.cancel()]
                    )
                }
                
                HStack {
                    Text("Сумма")
                    Spacer()
                    TextField("", text: $amount)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 120)
                }
                HStack {
                    Text("Дата")
                    Spacer()
                    DatePicker("", selection: $date, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                        .background(Color("MinorAccent"))
                        .cornerRadius(6)
                }
                HStack {
                    Text("Время")
                    Spacer()
                    DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .background(Color("MinorAccent"))
                        .cornerRadius(6)
                }
                TextField("Комментарий", text: $comment)
                    .multilineTextAlignment(.leading)
                
                if case let .edit(transaction) = mode {
                    Section {
                        Button(role: .destructive) {
                            deleteTransaction(transaction.id)
                        } label: {
                            Text("Удалить операцию")
                        }
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(mode.trailingToolbarButtonTitle) {
                        saveOrEditTransaction()
                    }
                    .font(.headline)
                    .foregroundColor(Color("ToolbarButton"))
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Закрыть") { dismiss() }
                    .foregroundColor(Color("ToolbarButton"))
                }
            }
            .alert(alertText, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            switch mode {
            case .create:
                break
            case .edit(let transaction):
                self.selectedCategory = categoriesViewModel.category(id: transaction.category.id)
            }
        }
    }
    
    //    var bindingAmount: Binding<String> {
    //        Binding(
    //            get: { amount },
    //            set: { newValue in
    //                let filtered = filterAmountString(newValue)
    //                if filtered.filter({ $0 == Character(decimalSeparator) }).count > 1 {
    //                    return
    //                }
    //                amount = filtered
    //            }
    //        )
    //    }
    //
    //    func filterAmountString(_ s: String) -> String {
    //        let allowedChars = CharacterSet(charactersIn: "0123456789\(decimalSeparator)")
    //        return String(s.filter { String($0).rangeOfCharacter(from: allowedChars) != nil })
    //    }
}

// MARK: - Transaction manipulate

private extension EditTransactionView {
    
    func deleteTransaction(_ id: Int) {
        Task {
            await transactionsViewModel.deleteTransaction(id)
            dismiss()
        }
    }
    
    func saveOrEditTransaction() {
        let amount = amount.replacingOccurrences(of: ",", with: ".")
        let comment = comment.isEmpty ? nil : comment
        guard
            let accountId = accountsViewModel.account?.id,
            let categoryId = selectedCategory?.id,
            !amount.isEmpty
        else {
            alertText = "Пожалуйста, заполните все поля и убедитесь, что сумма указана правильно"
            showAlert = true
            return
        }
        Task {
            let isCompleted: Bool
            switch mode {
            case .create:
                isCompleted = await transactionsViewModel.addTransaction(
                    accountId: accountId,
                    categoryId: categoryId,
                    amount: amount,
                    transactionDate: date,
                    comment: comment
                )
            case .edit(let transaction):
                isCompleted = await transactionsViewModel.editTransaction(
                    transactionId: transaction.id,
                    accountId: accountId,
                    categoryId: categoryId,
                    amount: amount,
                    transactionDate: date,
                    comment: comment
                )
            }

            if isCompleted {
                dismiss()
            } else {
                alertText = "Что-то пошло не так, проверьте данные и попробуйте еще раз"
                showAlert = true
            }
        }
    }
}
