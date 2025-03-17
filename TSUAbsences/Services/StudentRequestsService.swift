import Foundation
import UIKit

class StudentRequestsService {
    static let shared = StudentRequestsService()
    
    private init() {}
    
    func getMyRequests(pageable: PageableRequest, isAccepted: Bool? = nil) async throws -> PageableResponse<ShortPassRequestDTO> {
        var queryItems = [URLQueryItem]()
        
        if let isAccepted = isAccepted {
            queryItems.append(URLQueryItem(name: "isAccepted", value: String(isAccepted)))
        }
        
        queryItems.append(URLQueryItem(name: "page", value: String(pageable.page)))
        queryItems.append(URLQueryItem(name: "size", value: String(pageable.size)))
        
        if let sort = pageable.sort, !sort.isEmpty {
            for sortItem in sort {
                queryItems.append(URLQueryItem(name: "sort", value: sortItem))
            }
        }
        
        return try await NetworkManager.shared.request(
            endpoint: "/pass/request/my/pageable",
            method: "GET",
            body: EmptyRequest(),
            queryItems: queryItems
        )
    }
    
    func createRequest(dateStart: Date, dateEnd: Date, message: String?, files: [UIImage] = []) async throws -> ShortPassRequestDTO {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var urlComponents = URLComponents(string: NetworkManager.shared.baseURL + "/pass/request")!
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "dateStart", value: dateFormatter.string(from: dateStart)))
        queryItems.append(URLQueryItem(name: "dateEnd", value: dateFormatter.string(from: dateEnd)))
        
        if let message = message, !message.isEmpty {
            queryItems.append(URLQueryItem(name: "message", value: message))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let token = try? KeychainService.shared.loadToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if !files.isEmpty {
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            
            for (index, image) in files.enumerated() {
                let resizedImage = resizeImage(image, targetSize: CGSize(width: 800, height: 800))
                
                if let imageData = resizedImage.jpegData(compressionQuality: 0.3) {
                    var compressionQuality: CGFloat = 0.3
                    var compressedData = imageData
                    
                    while compressedData.count > 500 * 1024 && compressionQuality > 0.05 {
                        compressionQuality -= 0.05
                        if let newData = resizedImage.jpegData(compressionQuality: compressionQuality) {
                            compressedData = newData
                        }
                    }
                    
                    body.append("--\(boundary)\r\n".data(using: .utf8)!)
                    body.append("Content-Disposition: form-data; name=\"files\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
                    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                    body.append(compressedData)
                    body.append("\r\n".data(using: .utf8)!)
                }
            }
            
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response: \(responseString)")
        }
        
        if httpResponse.statusCode >= 400 {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.message)
            } else {
                throw NetworkError.serverError("Ошибка сервера: \(httpResponse.statusCode)")
            }
        }
        
        guard !data.isEmpty else {
            
            return try await getMyRequests(pageable: PageableRequest(page: 0, size: 1)).content.first ??
                ShortPassRequestDTO(
                    id: UUID().uuidString,
                    user: ShortUserDTO(id: "", fullName: "", role: .student),
                    dateStart: dateStart,
                    dateEnd: dateEnd,
                    minioFiles: [],
                    extendPassTimeRequests: [],
                    isAccepted: false,
                    createTimestamp: Date(),
                    message: message
                )
        }
        
        do {
            let decoder = JSONDecoder()
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            return try decoder.decode(ShortPassRequestDTO.self, from: data)
        } catch {
            return try await getMyRequests(pageable: PageableRequest(page: 0, size: 1)).content.first ??
                ShortPassRequestDTO(
                    id: UUID().uuidString,
                    user: ShortUserDTO(id: "", fullName: "", role: .student),
                    dateStart: dateStart,
                    dateEnd: dateEnd,
                    minioFiles: [],
                    extendPassTimeRequests: [],
                    isAccepted: false,
                    createTimestamp: Date(),
                    message: message
                )
        }
    }
    
    func deleteRequest(id: String) async throws {
        let urlString = NetworkManager.shared.baseURL + "/pass/request/\(id)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = try? KeychainService.shared.loadToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        if httpResponse.statusCode >= 400 {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.message)
            } else {
                throw NetworkError.serverError("Ошибка сервера: \(httpResponse.statusCode)")
            }
        }
    }
    
    func extendRequest(requestId: String, dateEnd: Date, message: String?, files: [UIImage] = []) async throws -> ShortPassRequestDTO {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var urlComponents = URLComponents(string: NetworkManager.shared.baseURL + "/pass/request/\(requestId)/extend")!
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "dateEnd", value: dateFormatter.string(from: dateEnd)))
        
        if let message = message, !message.isEmpty {
            queryItems.append(URLQueryItem(name: "message", value: message))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let token = try? KeychainService.shared.loadToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if !files.isEmpty {
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            
            for (index, image) in files.enumerated() {
                let resizedImage = resizeImage(image, targetSize: CGSize(width: 800, height: 800))
                
                if let imageData = resizedImage.jpegData(compressionQuality: 0.3) {
                    var compressionQuality: CGFloat = 0.3
                    var compressedData = imageData
                    
                    while compressedData.count > 500 * 1024 && compressionQuality > 0.05 {
                        compressionQuality -= 0.05
                        if let newData = resizedImage.jpegData(compressionQuality: compressionQuality) {
                            compressedData = newData
                        }
                    }
                    
                    body.append("--\(boundary)\r\n".data(using: .utf8)!)
                    body.append("Content-Disposition: form-data; name=\"files\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
                    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                    body.append(compressedData)
                    body.append("\r\n".data(using: .utf8)!)
                }
            }
            
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        if httpResponse.statusCode >= 400 {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.message)
            } else {
                throw NetworkError.serverError("Ошибка сервера: \(httpResponse.statusCode)")
            }
        }
        
        return try await getMyRequests(pageable: PageableRequest(page: 0, size: 1)).content.first ??
            ShortPassRequestDTO(
                id: requestId,
                user: ShortUserDTO(id: "", fullName: "", role: .student),
                dateStart: Date(),
                dateEnd: dateEnd,
                minioFiles: [],
                extendPassTimeRequests: [],
                isAccepted: false,
                createTimestamp: Date(),
                message: message
            )
    }
}

struct ErrorResponse: Decodable {
    let timestamp: String
    let status: Int
    let error: String
    let message: String
    let path: String
}

private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    var newSize: CGSize
    if widthRatio > heightRatio {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
    }
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: CGRect(origin: .zero, size: newSize))
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage ?? image
} 
