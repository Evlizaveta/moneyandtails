import Foundation
import SwiftUI

struct Currency: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let symbol: String
    let name: String
}

let availableCurrencies: [Currency] = [
    Currency(code: "RUB", symbol: "₽", name: "Российский рубль"),
    Currency(code: "USD", symbol: "$", name: "Американский доллар"),
    Currency(code: "EUR", symbol: "€", name: "Евро"),
]

struct AccountScreenView: View {
    
    @EnvironmentObject var accountsVM: AccountsViewModel
    @State private var isEditing = false
    @State private var showCurrencySheet = false
    @State private var editedBalance = ""
    @FocusState private var balanceFieldIsFocused: Bool

    var selectedCurrency: Currency {
        guard let currencyCode = accountsVM.account?.currency else { return availableCurrencies[0] }
        return availableCurrencies.first { $0.code == currencyCode } ?? availableCurrencies[0]
    }

    func formatBalanceInput(_ input: String) -> String {
        let allowed = "0123456789.,"
        let filtered = input.filter { allowed.contains($0) }
        let normalized = filtered.replacingOccurrences(of: ",", with: ".")
        return normalized
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                VStack(spacing: 16) {
                    Text("Мой счет")
                        .font(.largeTitle.bold())
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        if isEditing {
                            balanceFieldIsFocused = true
                        }
                    } label: {
                        HStack {
                            Text("💰")
                            Text("Баланс")
                            Spacer()
                            if isEditing {
                                TextField("", text: Binding(
                                    get: { editedBalance },
                                    set: { newValue in editedBalance = formatBalanceInput(newValue) }
                                ))
                                .keyboardType(.numberPad)
                                .focused($balanceFieldIsFocused)
                                .onAppear {
                                    if let acc = accountsVM.account {
                                        editedBalance = formatBalanceInput(acc.balance)
                                    }
                                }
                                Button("Paste", action: {
                                    if let copied = UIPasteboard.general.string {
                                        let filtered = copied.filter { "0123456789 ".contains($0) }
                                        editedBalance = formatBalanceInput(filtered)
                                    }
                                })
                                .foregroundColor(Color("ToolbarButton"))
                            } else {
                                Text(accountsVM.formatBalance(accountsVM.account?.balance ?? ""))
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 13).fill(.white))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    
                    Button {
                        if isEditing {
                            showCurrencySheet = true
                        }
                    } label: {
                        HStack {
                            Text("Валюта")
                                .foregroundColor(.primary)
                            Spacer()
                            HStack(spacing: 4) {
                                Text(selectedCurrency.symbol)
                                    .font(.title3.bold())
                                    .foregroundColor(.primary)
                                if isEditing {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 13).fill(.white))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 8)
                .refreshable {
                    await accountsVM.reloadMainAccount()
                }
            
                if showCurrencySheet {
                    CurrencyPickerSheet(
                        currencies: availableCurrencies,
                        selected: selectedCurrency,
                        onSelect: { currency in
                            if currency.code != accountsVM.account?.currency {
                                Task {
                                    guard let acc = accountsVM.account else { return }
                                    await accountsVM.updateAccount(accountId: acc.id, name: acc.name, balance: acc.balance, currency: currency.code)
                                }
                            }
                        },
                        onDismiss: {
                            showCurrencySheet = false
                        }
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("Сохранить") {
                            Task {
                                guard let acc = accountsVM.account else { return }
                                let newBalance = editedBalance.replacingOccurrences(of: " ", with: "")
                                await accountsVM.updateAccount(accountId: acc.id, name: acc.name, balance: newBalance, currency: acc.currency)
                                isEditing = false
                                balanceFieldIsFocused = false
                            }
                        }
                        .foregroundColor(Color("ToolbarButton"))
                    } else {
                        Button("Редактировать") {
                            isEditing = true
                        }
                        .foregroundColor(Color("ToolbarButton"))
                    }
                }
            }
            
            .onTapGesture {
                if isEditing {
                    balanceFieldIsFocused = false
                }
            }
            
            .onChange(of: isEditing) { newValue in
                if newValue == false {
                    Task {
                        guard let acc = accountsVM.account else { return }
                        let newBalance = editedBalance.replacingOccurrences(of: " ", with: "")
                        await accountsVM.updateAccount(accountId: acc.id, name: acc.name, balance: newBalance, currency: acc.currency)
                        balanceFieldIsFocused = false
                    }
                }
            }
            .task {
                if accountsVM.account == nil {
                    await accountsVM.reloadMainAccount()
                }
            }
        }
    }
}

struct CurrencyPickerSheet: View {
    let currencies: [Currency]
    let selected: Currency?
    let onSelect: (Currency) -> Void
    let onDismiss: () -> Void
    @EnvironmentObject var accountVM: AccountsViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    Text("Валюта")
                        .font(.system(size: 15))
                        .foregroundColor(.black)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    Divider()
                    ForEach(currencies) { currency in
                        Button {
                            onSelect(currency)
                            onDismiss()
                        } label: {
                            Text("\(currency.name) \(currency.symbol)")
                                .font(.system(size: 18))
                                .foregroundColor(Color("ToolbarButton"))
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .padding(.vertical, 2)
                        }
                        if currency != currencies.last {
                            Divider()
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(26)
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}
