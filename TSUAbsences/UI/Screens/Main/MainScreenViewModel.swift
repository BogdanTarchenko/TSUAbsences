import Foundation

final class MainScreenViewModel: ObservableObject {
    @Published var userRole: UserRole?
    
    func fetchUserRole() {
        Task {
            do {
                let profile: UserProfile = try await NetworkManager.shared.request(
                    endpoint: "/user/profile",
                    method: "GET",
                    body: EmptyRequest()
                )
                
                await MainActor.run {
                    self.userRole = profile.role
                }
            } catch {
                print("Error fetching user role: \(error)")
            }
        }
    }
} 
