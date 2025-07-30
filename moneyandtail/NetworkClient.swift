//
//  NetworkClient.swift
//  moneyandtail
//
//  Created by Лиза on 18.07.2025.
//

import Foundation

final class NetworkClient {
    let session: URLSession
    private let baseURL: URL
    private let token: String
    
    init(baseURL: URL, token: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.token = token
        self.session = session
    }
    
    enum NetworkError: Error, LocalizedError {
        case invalidURL
        case http(status: Int, data: Data)
        case noData
        case serialization(Error)
        case deserialization(Error)
        case underlying(Error)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Некорректный URL"
            case .http(let status, _): return "Сервер вернул ошибку (\(status))"
            case .noData: return "Нет данных"
            case .serialization(let e): return "Ошибка кодирования (\(e.localizedDescription))"
            case .deserialization(let e): return "Ошибка декодирования (\(e.localizedDescription))"
            case .underlying(let e): return "Неизвестная ошибка (\(e.localizedDescription))"
            }
        }
    }
    
    func request<RequestBody: Encodable, ResponseBody: Decodable>(
        path: String,
        method: String = "GET",
        requestBody: RequestBody? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> ResponseBody {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = queryItems
        
        guard let url = components.url else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = requestBody {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.serialization(error)
            }
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw NetworkError.noData }
            guard (200...299).contains(http.statusCode) else {
                throw NetworkError.http(status: http.statusCode, data: data)
            }
            do {
                let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
                return decoded
            } catch {
                throw NetworkError.deserialization(error)
            }
        } catch {
            throw NetworkError.underlying(error)
        }
    }
}
