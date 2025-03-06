import Foundation

struct UserProfile: Codable {
    let id: String
    let email: String
    let fullName: String
    let group: GroupDTO
    let role: UserRole
    let isBlocked: Bool
}

enum UserRole: String, Codable {
    case admin
    case deanery
    case teacher
    case student
} 