import Foundation

struct RegistrationRequest: Encodable {
    let fullName: String
    let email: String
    let groupNumber: Int?
    let password: String
} 
