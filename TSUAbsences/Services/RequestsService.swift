import Foundation

class RequestsService {
    static let shared = RequestsService()
    
    private init() {}
    
    func getRequests(
        userId: String? = nil,
        filter: RequestsFilter,
        pageable: PageableRequest
    ) async throws -> PageableResponse<ShortPassRequestDTO> {
        var queryItems: [URLQueryItem] = []
        
        if let userId = userId {
            queryItems.append(URLQueryItem(name: "userId", value: userId))
        }
        
        if let userSearchString = filter.userSearchString {
            queryItems.append(URLQueryItem(name: "userSearchString", value: userSearchString))
        }
        
        if let dateStart = filter.dateStart {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: dateStart)
            let dateFormatter = ISO8601DateFormatter()
            queryItems.append(URLQueryItem(name: "dateStart", value: dateFormatter.string(from: startOfDay)))
        }
        
        if let dateEnd = filter.dateEnd {
            let calendar = Calendar.current
            var components = DateComponents()
            components.day = 1
            components.second = -1
            let endOfDay = calendar.date(byAdding: components, to: calendar.startOfDay(for: dateEnd)) ?? dateEnd
            let dateFormatter = ISO8601DateFormatter()
            queryItems.append(URLQueryItem(name: "dateEnd", value: dateFormatter.string(from: endOfDay)))
        }
        
        if let isAccepted = filter.isAccepted {
            queryItems.append(URLQueryItem(name: "isAccepted", value: String(isAccepted)))
        }
        
        queryItems.append(URLQueryItem(name: "page", value: String(pageable.page)))
        queryItems.append(URLQueryItem(name: "size", value: String(pageable.size)))
        
        if let sort = pageable.sort {
            sort.forEach { sortItem in
                queryItems.append(URLQueryItem(name: "sort", value: sortItem))
            }
        }
        
        return try await NetworkManager.shared.request(
            endpoint: "/pass/request/pageable",
            method: "GET",
            body: EmptyRequest(),
            queryItems: queryItems
        )
    }
}
