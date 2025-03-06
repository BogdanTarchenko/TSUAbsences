import Foundation

enum ValidationError: Error {
    case emptyField(String)
    case invalidEmail
    case passwordMismatch
    case invalidGroupNumber
    
    var message: String {
        switch self {
        case .emptyField(let field):
            return "Поле '\(field)' не может быть пустым"
        case .invalidEmail:
            return "Введите корректный email"
        case .passwordMismatch:
            return "Пароли не совпадают"
        case .invalidGroupNumber:
            return "Неверный номер группы"
        }
    }
}

struct Validation {
    static func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func validateNonEmpty(_ value: String, fieldName: String) throws {
        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError.emptyField(fieldName)
        }
    }
} 