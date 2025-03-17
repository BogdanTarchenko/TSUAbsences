import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case validationError(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .noData:
            return "Нет данных"
        case .decodingError:
            return "Ошибка обработки данных"
        case .serverError(let message):
            return message
        case .validationError(let message):
            return message
        case .unknownError:
            return "Неизвестная ошибка"
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    let baseURL = "http://83.222.26.250:8080"
    
    private init() {}
    
    func request<T: Encodable, R: Decodable>(
        endpoint: String,
        method: String = "POST",
        body: T = EmptyRequest(),
        queryItems: [URLQueryItem]? = nil
    ) async throws -> R {
        var urlComponents = URLComponents(string: baseURL + endpoint)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = try? KeychainService.shared.loadToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if method != "GET" {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            request.httpBody = try encoder.encode(body)
        }
        
        if let bodyData = request.httpBody,
           let bodyString = String(data: bodyData, encoding: .utf8) {
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            do {
                let errorResponse = try JSONDecoder().decode(ApiErrorResponse.self, from: data)
                throw NetworkError.serverError(errorResponse.message)
            } catch DecodingError.keyNotFound(_, _),
                    DecodingError.valueNotFound(_, _),
                    DecodingError.typeMismatch(_, _),
                    DecodingError.dataCorrupted(_) {
                throw NetworkError.serverError("Ошибка сервера: \(httpResponse.statusCode)")
            } catch let error as NetworkError {
                throw error
            } catch {
                throw NetworkError.unknownError
            }
        }
        
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(R.self, from: data)
            return response
        } catch {
            throw NetworkError.decodingError
        }
    }
} 
