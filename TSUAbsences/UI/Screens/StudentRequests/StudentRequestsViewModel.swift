import Foundation
import SwiftUI
import UIKit

@MainActor
class StudentRequestsViewModel: ObservableObject {
    @Published var requests: [ShortPassRequestDTO] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showingCreateForm = false
    @Published var showingExtendForm = false
    
    @Published var currentPage = 0
    @Published var hasMorePages = true
    @Published var selectedStatus: RequestStatus = .all
    
    @Published var newRequestDateStart = Date()
    @Published var newRequestDateEnd = Date()
    @Published var newRequestMessage = ""
    @Published var selectedImages: [UIImage] = []
    
    @Published var selectedRequestForExtend: ShortPassRequestDTO? = nil
    @Published var extendRequestDateEnd = Date()
    @Published var extendRequestMessage = ""
    @Published var extendSelectedImages: [UIImage] = []
    
    @Published var showError = false
    @Published var errorMessage: String?
    
    private let pageSize = 10
    
    enum RequestStatus: String, CaseIterable, Identifiable {
        case all = "Все"
        case accepted = "Принятые"
        case rejected = "Отклоненные"
        
        var id: String { self.rawValue }
        
        var filterValue: Bool? {
            switch self {
            case .all: return nil
            case .accepted: return true
            case .rejected: return false
            }
        }
    }
    
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
            print("📤 Отправка запроса на получение заявок:")
            print("📄 Страница: \(currentPage), Размер: \(pageSize)")
            print("🔍 Статус фильтра: \(selectedStatus.rawValue)")
            
            let response = try await StudentRequestsService.shared.getMyRequests(
                pageable: pageable,
                isAccepted: selectedStatus.filterValue
            )
            
            print("📥 Получено заявок: \(response.content.count)")
            
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
            print("❌ Ошибка загрузки заявок: \(error)")
            if let networkError = error as? NetworkError {
                print("🌐 Сетевая ошибка: \(networkError.localizedDescription)")
            }
            
            if forceRefresh {
                print("🔄 Ошибка при обновлении: \(error.localizedDescription)")
            } else {
                self.error = error
            }
        }
        
        isLoading = false
    }
    
    func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    func createRequest() async {
        guard !selectedImages.isEmpty else {
            showErrorAlert("Необходимо прикрепить хотя бы один файл")
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let message = newRequestMessage.isEmpty ? nil : newRequestMessage
            let newRequest = try await StudentRequestsService.shared.createRequest(
                dateStart: newRequestDateStart,
                dateEnd: newRequestDateEnd,
                message: message,
                files: selectedImages
            )
            
            await loadRequests(forceRefresh: true)
            
            showingCreateForm = false
            
            newRequestDateStart = Date()
            newRequestDateEnd = Date()
            newRequestMessage = ""
            selectedImages = []
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func deleteRequest(id: String) async {
        guard let request = requests.first(where: { $0.id == id }),
              request.isAccepted == nil else {
            self.error = NetworkError.serverError("Можно удалять только заявки, которые находятся на рассмотрении")
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            try await StudentRequestsService.shared.deleteRequest(id: id)
            
            requests.removeAll { $0.id == id }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func addImage(_ image: UIImage) {
        selectedImages.append(image)
    }
    
    func removeImage(at index: Int) {
        if index >= 0 && index < selectedImages.count {
            selectedImages.remove(at: index)
        }
    }
    
    func prepareForExtend(request: ShortPassRequestDTO) {
        guard request.isAccepted == true else {
            self.error = NetworkError.serverError("Продлить можно только принятые заявки")
            return
        }
        
        selectedRequestForExtend = request
        extendRequestDateEnd = request.dateEnd.addingTimeInterval(7 * 24 * 60 * 60)
        extendRequestMessage = ""
        extendSelectedImages = []
        showingExtendForm = true
    }
    
    func extendRequest() async {
        guard !extendSelectedImages.isEmpty else {
            showErrorAlert("Необходимо прикрепить хотя бы один файл")
            return
        }
        
        guard let request = selectedRequestForExtend else { return }
        
        isLoading = true
        error = nil
        
        do {
            let message = extendRequestMessage.isEmpty ? nil : extendRequestMessage
            _ = try await StudentRequestsService.shared.extendRequest(
                requestId: request.id,
                dateEnd: extendRequestDateEnd,
                message: message,
                files: extendSelectedImages
            )
            
            await loadRequests(forceRefresh: true)
            
            showingExtendForm = false
            
            selectedRequestForExtend = nil
            extendRequestDateEnd = Date()
            extendRequestMessage = ""
            extendSelectedImages = []
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func addExtendImage(_ image: UIImage) {
        extendSelectedImages.append(image)
    }
    
    func removeExtendImage(at index: Int) {
        if index >= 0 && index < extendSelectedImages.count {
            extendSelectedImages.remove(at: index)
        }
    }
} 
