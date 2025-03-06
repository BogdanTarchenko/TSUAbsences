import Foundation

struct ApiErrorResponse: Decodable {
    let timestamp: String
    let status: Int
    let error: String
    let message: String
    let errorDetails: [String: String]?
    let path: String
} 