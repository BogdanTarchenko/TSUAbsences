import Foundation

final class GroupSelectionViewModel: ObservableObject {
    @Published var groups: [GroupDTO] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func fetchGroups() {
        Task {
            await MainActor.run { isLoading = true }
            
            do {
                let groups: [GroupDTO] = try await NetworkManager.shared.request(
                    endpoint: "/group/list",
                    method: "GET",
                    body: EmptyRequest()
                )
                
                await MainActor.run {
                    self.groups = groups.sorted { $0.groupNumber < $1.groupNumber }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

extension Int {
    var groupString: String {
        return String(format: "%d", self)
    }
}

struct EmptyRequest: Encodable {} 