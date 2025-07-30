//
//  Config.swift
//  moneyandtail
//
//  Created by Лиза on 19.07.2025.
//

import Foundation

struct AppConfig {
    static let shared = AppConfig()
    
    static let baseURL = URL(string: "https://shmr-finance.ru/api/v1")!
    static let token = "CLeoZComaJAdDokJg4XzaYT7"
}
