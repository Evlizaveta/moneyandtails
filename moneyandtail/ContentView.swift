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
        TabView {
            TransactionsListView(
                direction: .outcome,
                availableCategories: categories
            )
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                        .renderingMode(.template)
                    Text("Расходы")
                }
            
        TransactionsListView(direction: .income,
                             availableCategories: categories
                             )
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                        .renderingMode(.template)
                    Text("Доходы")
                }
            
            AccountScreenView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                        .renderingMode(.template)
                    Text("Счёт")
                }
            MyArticlesView()
                .tabItem {
                    Image(systemName: "lineweight")
                        .renderingMode(.template)
                    Text("Статьи")
                }
            
            Text("Настройки")
                .tabItem {
                    Image(systemName: "person.crop.circle")
                        .renderingMode(.template)
                    Text("Настройки")
                }
        }
        .accentColor(Color("AccentColor"))
    }
}


#Preview {
    ContentView(categories: [
        Category(id: 1, name: "Продукты", emoji: "🍎", direction: .outcome),
        Category(id: 2, name: "Зарплата", emoji: "💰", direction: .income)
    ])
}
