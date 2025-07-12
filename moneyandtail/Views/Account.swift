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

struct CurrencyPickerSheet: View {
    let currencies: [Currency]
    let selected: Currency?
    let onSelect: (Currency) -> Void
    let onDismiss: () -> Void

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
                                .foregroundColor(Color(.purple))
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
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

struct AccountScreenView: View {
    @State private var account: Account?
    @State private var isEditing = false
    @State private var showCurrencySheet = false
    @State private var editedBalance = ""
    @FocusState private var balanceFieldIsFocused: Bool

    let service = AccountServiceMock()

    var selectedCurrency: Currency {
        guard let currencyCode = account?.currency else { return availableCurrencies[0] }
        return availableCurrencies.first { $0.code == currencyCode } ?? availableCurrencies[0]
    }

    func formatBalanceInput(_ input: String) -> String {
        let digits = input.filter { $0.isWholeNumber }
        guard let value = Int(digits) else { return "" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? digits
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Мой счет")
                            .font(.largeTitle.bold())
                            .padding(.top, 16)
                            .padding(.leading)
                        Button {
                            if isEditing {
                                balanceFieldIsFocused = true
                            }
                        } label: {
                            HStack {
                                Text("Баланс")
                                    .foregroundColor(.primary)
                                Spacer()
                                if isEditing {
                                    TextField("", text: Binding(
                                        get: {
                                            editedBalance
                                        },
                                        set: { newValue in
                                            editedBalance = formatBalanceInput(newValue)
                                        }
                                    ))
                                    .keyboardType(.numberPad)
                                    .focused($balanceFieldIsFocused)
                                    .frame(width: 120)
                                    .multilineTextAlignment(.trailing)
                                    .onAppear {
                                        if let acc = account {
                                            editedBalance = formatBalanceInput(String(NSDecimalNumber(decimal: acc.balance).intValue))
                                        }
                                    }
                                    Button("Paste", action: {
                                        if let copied = UIPasteboard.general.string {
                                            let filtered = copied.filter { "0123456789 ".contains($0) }
                                            editedBalance = formatBalanceInput(filtered)
                                        }
                                    })
                                } else {
                                    Text("\(account?.balance as NSDecimalNumber? ?? 0, formatter: balanceFormatter)")
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 18).fill(.white))
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
                            .background(RoundedRectangle(cornerRadius: 18).fill(.white))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
                
                if showCurrencySheet {
                    CurrencyPickerSheet(
                        currencies: availableCurrencies,
                        selected: selectedCurrency,
                        onSelect: { currency in
                            if currency.code != account?.currency {
                                Task {
                                    if var acc = account {
                                        acc.currency = currency.code
                                        await service.update(account: acc)
                                        account = acc
                                    }
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
                                if var acc = account,
                                   let newBalance = Decimal(string: editedBalance.replacingOccurrences(of: " ", with: ""))
                                {
                                    acc.balance = newBalance
                                    await service.update(account: acc)
                                    account = acc
                                }
                                isEditing = false
                                balanceFieldIsFocused = false
                            }
                        }
                    } else {
                        Button("Редактировать") {
                            isEditing = true
                        }
                        .foregroundColor(.purple)
                    }
                }
            }
            .onTapGesture {
                if isEditing {
                    balanceFieldIsFocused = false
                }
            }
            .task {
                if account == nil {
                    account = await service.getFirstAccount()
                }
            }
            .refreshable {
                await reloadAccountData()
            }
        }
    }
    
    var balanceFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 0
        f.groupingSeparator = " "
        f.numberStyle = .decimal
        return f
    }
    func reloadAccountData() async {
        account = await service.getFirstAccount()
    }
}

struct AccountScreenView_Previews: PreviewProvider {
    static var previews: some View {
        AccountScreenView()
    }
}
