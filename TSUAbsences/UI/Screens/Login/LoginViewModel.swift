import Foundation
import SwiftUI

final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func login() {
        do {
            try Validation.validateNonEmpty(email, fieldName: "Email")
            try Validation.validateNonEmpty(password, fieldName: "Пароль")
            
            if !Validation.validateEmail(email) {
                errorMessage = ValidationError.invalidEmail.message
                return
            }
            
            let request = LoginRequest(email: email, password: password)
            
            Task {
                await MainActor.run { isLoading = true }
                
                do {
                    let response: AuthResponse = try await NetworkManager.shared.request(
                        endpoint: "/auth/login",
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
