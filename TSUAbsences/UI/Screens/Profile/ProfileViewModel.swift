import Foundation
import SwiftUI

final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    func fetchProfile() {
        Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                let profile: UserProfile = try await NetworkManager.shared.request(
                    endpoint: "/user/profile",
                    method: "GET",
                    body: EmptyRequest()
                )
                
                await MainActor.run {
                    self.profile = profile
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    @MainActor
    func logout() {
        Task {
            do {
                try KeychainService.shared.deleteToken()
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = UIHostingController(rootView: WelcomeScreen())
                }
            } catch {
                self.errorMessage = "Ошибка при выходе"
                self.showError = true
            }
        }
    }
} 