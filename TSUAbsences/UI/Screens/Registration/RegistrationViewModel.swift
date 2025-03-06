import Foundation
import SwiftUI

final class RegistrationViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var groupNumberText: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var groupNumber: Int? {
        return Int(groupNumberText)
    }
    
    func register() {
        do {
            try Validation.validateNonEmpty(fullName, fieldName: "ФИО")
            try Validation.validateNonEmpty(email, fieldName: "Email")
            try Validation.validateNonEmpty(password, fieldName: "Пароль")
            try Validation.validateNonEmpty(confirmPassword, fieldName: "Подтверждение пароля")
            
            if !Validation.validateEmail(email) {
                errorMessage = ValidationError.invalidEmail.message
                return
            }
            
            guard password == confirmPassword else {
                errorMessage = ValidationError.passwordMismatch.message
                return
            }
            
            if !Validation.validateGroupNumber(groupNumberText) {
                errorMessage = ValidationError.invalidGroupNumber.message
                return
            }
            
            let request = RegistrationRequest(
                fullName: fullName,
                email: email,
                groupNumber: Int(groupNumberText),
                password: password
            )
            
            Task {
                await MainActor.run { isLoading = true }
                
                do {
                    let response: AuthResponse = try await NetworkManager.shared.request(
                        endpoint: "/auth/registration",
                        body: request
                    )
                    
                    try KeychainService.shared.saveToken(response.token)
                    
                    await MainActor.run {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController = UIHostingController(rootView: MainScreen())
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                    }
                }
                
                await MainActor.run { isLoading = false }
            }
        } catch ValidationError.emptyField(let field) {
            errorMessage = ValidationError.emptyField(field).message
        } catch {
            errorMessage = "Неизвестная ошибка"
        }
    }
} 
