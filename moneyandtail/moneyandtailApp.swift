//
//  moneyandtailApp.swift
//  moneyandtail
//
//  Created by Лиза on 11.06.2025.
//


import SwiftUI

@main
struct MyProjectNameApp: App {
    @StateObject private var transactionsVM: TransactionsViewModel
        @StateObject private var accountsVM: AccountsViewModel
        @StateObject private var categoriesVM: CategoriesViewModel

        init() {
            let client = NetworkClient(baseURL: AppConfig.baseURL, token: AppConfig.token)
            let transactionsService = TransactionsService(client: client)
            let accountsService = AccountsService(client: client)
            let categoriesService = CategoriesService(client: client)

            _transactionsVM = StateObject(wrappedValue: TransactionsViewModel(service: transactionsService, direction: .income))
            _accountsVM = StateObject(wrappedValue: AccountsViewModel(service: accountsService))
            _categoriesVM = StateObject(wrappedValue: CategoriesViewModel(service: categoriesService))
        }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(transactionsVM)
                .environmentObject(accountsVM)
                .environmentObject(categoriesVM)
        }
    }
}
