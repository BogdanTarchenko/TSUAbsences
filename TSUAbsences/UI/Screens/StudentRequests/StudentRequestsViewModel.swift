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
    
    private let pageSize = 10
    
    enum RequestStatus: String, CaseIterable, Identifiable {
        case all = "Все"
        case accepted = "Принятые"
        case pending = "На рассмотрении"
        
        var id: String { self.rawValue }
        
        var isAcceptedValue: Bool? {
            switch self {
            case .all: return nil
            case .accepted: return true
            case .pending: return false
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
            let response = try await StudentRequestsService.shared.getMyRequests(
                pageable: pageable,
                isAccepted: selectedStatus.isAcceptedValue
            )
            
            // Проверяем на дубликаты
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
    
    func createRequest() async {
        // Проверка наличия файлов
        guard !selectedImages.isEmpty else {
            self.error = NetworkError.serverError("Необходимо прикрепить хотя бы один файл")
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
            
            // Обновляем список заявок
            await loadRequests(forceRefresh: true)
            
            showingCreateForm = false
            
            // Сбрасываем данные для следующего создания
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
        // Проверяем, что заявка существует и не принята
        guard let request = requests.first(where: { $0.id == id }),
              !request.isAccepted else {
            self.error = NetworkError.serverError("Можно удалять только заявки, которые еще не рассмотрены")
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            try await StudentRequestsService.shared.deleteRequest(id: id)
            
            // Удаляем заявку из списка
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
        selectedRequestForExtend = request
        extendRequestDateEnd = request.dateEnd.addingTimeInterval(7 * 24 * 60 * 60) // +7 дней по умолчанию
        extendRequestMessage = ""
        extendSelectedImages = []
        showingExtendForm = true
    }
    
    func extendRequest() async {
        guard let request = selectedRequestForExtend else { return }
        
        // Проверка наличия файлов
        guard !extendSelectedImages.isEmpty else {
            self.error = NetworkError.serverError("Необходимо прикрепить хотя бы один файл")
            return
        }
        
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
            
            // Обновляем список заявок
            await loadRequests(forceRefresh: true)
            
            showingExtendForm = false
            
            // Сбрасываем данные
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
