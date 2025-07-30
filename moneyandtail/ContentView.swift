//
//  ContentView.swift
//  moneyandtail
//
//  Created by Лиза on 11.06.2025.
//

import SwiftUI

struct ContentView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            TabView {
                TransactionsListView(
                    direction: .outcome
                )
                .tabItem {
                    Image("Outcome")
                        .renderingMode(.template)
                    Text("Расходы")
                }
                
                TransactionsListView(
                    direction: .income
                )
                .tabItem {
                    Image("Income")
                        .renderingMode(.template)
                    Text("Доходы")
                }
                
                AccountScreenView()
                    .tabItem {
                        Image("Account")
                            .renderingMode(.template)
                        Text("Счёт")
                    }
                
                MyArticlesView()
                    .tabItem {
                        Image("Articles")
                            .renderingMode(.template)
                        Text("Статьи")
                    }
                
                Text("Настройки")
                    .tabItem {
                        Image("Settings")
                            .renderingMode(.template)
                        Text("Настройки")
                    }
            }
            .accentColor(Color("AccentColor"))
        }
    }
}


//#Preview {
//    ContentView()
//}
