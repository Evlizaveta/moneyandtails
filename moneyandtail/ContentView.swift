//
//  ContentView.swift
//  moneyandtail
//
//  Created by Лиза on 11.06.2025.
//

import SwiftUI

struct ContentView: View {
    let categories =
    MockData.mockCategories
    
    var body: some View {
        TabView {
            
            
            TransactionsListView(
                direction: .income,
                availableCategories: categories.filter { $0.direction == .income }
            )
            .tabItem {
                                Image(systemName: "chart.bar.xaxis")
                                    .renderingMode(.template)
                                Text("Доходы")
                            }
            
            TransactionsListView(
                direction: .outcome,
                availableCategories: categories.filter { $0.direction == .outcome }
            )
            .tabItem {
                                Image(systemName: "chart.bar.xaxis")
                                    .renderingMode(.template)
                                Text("Расходы")
                            }
            
            AccountScreenView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                        .renderingMode(.template)
                    Text("Счёт")
                }
            MyArticlesView(categories: categories)
                .tabItem {
                    Image(systemName: "lineweight")
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
    ContentView()
}
