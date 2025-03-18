import Foundation

struct PageableRequest: Codable {
    let page: Int
    let size: Int
    let sort: [String]?
    
    init(page: Int = 0, size: Int = 10, sort: [String]? = nil) {
        self.page = page
        self.size = size
        self.sort = sort
    }
}

struct RequestsFilter {
    let userSearchString: String?
    let dateStart: Date?
    let dateEnd: Date?
    let isAccepted: Bool?
    let isAcceptedExplicitlyNull: Bool
    
    init(
        userSearchString: String? = nil,
        dateStart: Date? = nil,
        dateEnd: Date? = nil,
        isAccepted: Bool? = nil,
        isAcceptedExplicitlyNull: Bool = false
    ) {
        self.userSearchString = userSearchString
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.isAccepted = isAccepted
        self.isAcceptedExplicitlyNull = isAcceptedExplicitlyNull
    }
} 
