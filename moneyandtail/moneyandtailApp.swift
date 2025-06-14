//
//  moneyandtailApp.swift
//  moneyandtail
//
//  Created by Лиза on 11.06.2025.
//

// подгружать данные из json, по новой все джсоны загрузить

import SwiftUI

@main
struct MyProjectNameApp: App {
    func loadCategoriesFromFile() -> [Category] {
        guard let url = Bundle.main.url(forResource: "response_1749817892008", withExtension: "json") else {
            print("Файл contents.json не найден")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let categories = try JSONDecoder().decode([Category].self, from: data)
            return categories
        } catch {
            print("Ошибка при чтении JSON: \(error)")
            return []
        }
    }

    var body: some Scene {
        WindowGroup {
            let categories = loadCategoriesFromFile()  // [Category]
            ContentView(categories: categories)       // Передаём [Category], не [CategoryViewModel]
        }
    }
}
