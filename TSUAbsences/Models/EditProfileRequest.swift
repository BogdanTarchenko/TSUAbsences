import Foundation

struct EditProfileRequest: Encodable {
    let fullName: String?
    let group: Int?
    let email: String?
} 
