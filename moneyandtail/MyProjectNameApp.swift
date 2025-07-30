//
//  moneyandtailApp.swift
//  moneyandtail
//
//  Created by Лиза on 11.06.2025.
//


import SwiftUI

@main
struct MyProjectNameApp: App {

    let client = NetworkClient(baseURL: AppConfig.baseURL, token: AppConfig.token)

    @StateObject private var transactionsVM: TransactionsViewModel
    @StateObject private var accountsVM: AccountsViewModel
    @StateObject private var categoriesVM: CategoriesViewModel

    init() {
        let transactionsService = TransactionsService(client: client)
        let accountsService = AccountsService(client: client)
        let categoriesService = CategoriesService(client: client)

        let accountsVM = AccountsViewModel(
            service: accountsService
        )
        self._accountsVM = StateObject(wrappedValue: accountsVM)

        let transactionsVM = TransactionsViewModel(
            service: transactionsService,
            accountsViewModel: accountsVM
        )
        self._transactionsVM = StateObject(wrappedValue: transactionsVM)

        let categoriesVM = CategoriesViewModel(
            service: categoriesService,
            accountsVM: accountsVM
        )
        self._categoriesVM = StateObject(wrappedValue: categoriesVM)
        Task {
            await accountsVM.reloadMainAccount()
        }
    }

    var body: some Scene {
        WindowGroup {
            AnimatedScreenView()
                .environmentObject(transactionsVM)
                .environmentObject(accountsVM)
                .environmentObject(categoriesVM)
        }
    }
}
