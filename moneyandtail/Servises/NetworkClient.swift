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
            //case .http(let status, _): return "Сервер вернул ошибку (\(status))"
            case .http(let status, let data):
                let message = String(data: data, encoding: .utf8) ?? "Нет описания ошибки"
                return "Сервер вернул ошибку (\(status)): \(message)"

            case .noData: return "Нет данных"
            case .serialization(let e): return "Ошибка кодирования (\(e.localizedDescription))"
            case .deserialization(let e): return "Ошибка декодирования (\(e.localizedDescription))"
            case .underlying(let e): return "Неизвестная ошибка (\(e.localizedDescription))"
                
            }
        }
    }
    
    enum RequestMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case put = "PUT"
    }
    
    func request<ResponseBody: Decodable>(
        path: String,
        method: RequestMethod,
        requestBody: Encodable? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> ResponseBody {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = queryItems
        
        guard let url = components.url else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        if let body = requestBody {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let jsonData = try encoder.encode(body)
//                if let jsonString = String(data: jsonData, encoding: .utf8) {
//                    print("Request JSON body: \(jsonString)")
//                }
                request.httpBody = jsonData
            } catch {
                throw NetworkError.serialization(error)
            }
        }
        
        do {
            guard let url = components.url else { throw NetworkError.invalidURL }
//            print("Request URL:", url.absoluteString)

            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw NetworkError.noData }
            guard (200...299).contains(http.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Нет описания ошибки"
//                print(" Сервер вернул ошибку \(http.statusCode): \(errorMessage)")
                throw NetworkError.http(status: http.statusCode, data: data)
            }

            do {
                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                let formats = [
                    "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", // с миллисекундами
                    "yyyy-MM-dd'T'HH:mm:ss'Z'"      // без миллисекунд
                ]

                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)

                    for format in formats {
                        formatter.dateFormat = format
                        if let date = formatter.date(from: dateString) {
                            return date
                        }
                    }

                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Cannot decode date string: \(dateString)"
                    )
                }
                let decoded = try decoder.decode(ResponseBody.self, from: data)
                return decoded
            } catch {
                throw NetworkError.deserialization(error)
            }
        } catch {
            throw NetworkError.underlying(error)
        }
    }
}
