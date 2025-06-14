//
//  ContentView.swift
//  moneyandtail
//
//  Created by Лиза on 11.06.2025.
//

import SwiftUI

struct ContentView: View {
    let categories: [Category]

    var body: some View {
        List(categories) { category in
            let viewModel = CategoryViewModel(category: category)

            HStack {
               // Text(viewModel.icon)
                   // .font(.largeTitle)
                VStack(alignment: .leading) {
                    Text(viewModel.title)
                        .font(.headline)
                    Text(viewModel.isIncome == .income ? "Доход" : "Расход")
                        .foregroundColor(viewModel.isIncome == .income ? .green : .red)
                        .font(.subheadline)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// #Preview {
//     ContentView(categories: [
//         Category(id: "1", name: "Продукты", emoji: "🍎", direction: .outcome),
//         Category(id: "2", name: "Зарплата", emoji: "💰", direction: .income)
//     ])
// }
