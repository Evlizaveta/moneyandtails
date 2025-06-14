//
//  AccoutServiseMock.swift
//  moneyandtail
//
//  Created by Лиза on 13.06.2025.
//

import Foundation

final class AccountServiceMock {
    private var accounts: [Account] =  [MockData.mockAccount]
    
    func getFirstAccount() async -> Account? {
        return accounts.first
    }

    func update(account: Account) async {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
        }
    }
}
