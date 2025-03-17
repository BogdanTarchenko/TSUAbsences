import Foundation
import SwiftUI

@MainActor
class RequestsViewModel: ObservableObject {
    @Published var requests: [ShortPassRequestDTO] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    @Published var filter = RequestsFilter()
    @Published var currentPage = 0
    @Published var hasMorePages = true
    
    private let pageSize = 10
    
    func loadRequests(forceRefresh: Bool = false) async {
        if forceRefresh {
            currentPage = 0
            requests = []
            hasMorePages = true
        }
        
        guard hasMorePages && !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let pageable = PageableRequest(page: currentPage, size: pageSize)
            let response = try await RequestsService.shared.getRequests(filter: filter, pageable: pageable)
            
            let newRequests = response.content.filter { newRequest in
                !requests.contains { existingRequest in
                    existingRequest.id == newRequest.id
                }
            }
            
            if forceRefresh {
                requests = newRequests
            } else {
                requests.append(contentsOf: newRequests)
            }
            
            hasMorePages = !response.last
            currentPage = Int(response.number) + 1
        } catch {
            if forceRefresh {
                print("Ошибка при обновлении: \(error.localizedDescription)")
            } else {
                self.error = error
            }
        }
        
        isLoading = false
    }
    
    func applyFilter() async {
        await loadRequests(forceRefresh: true)
    }
} 
