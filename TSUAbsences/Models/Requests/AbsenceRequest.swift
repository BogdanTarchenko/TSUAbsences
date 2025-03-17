import Foundation

struct ShortUserDTO: Codable {
    let id: String
    let fullName: String
    let role: UserRole
}

struct ShortMinioFileDTO: Codable {
    let id: String
    let name: String
}

struct ShortExtendPassTimeRequestDTO: Codable {
    let id: String
    let dateEnd: Date
    let minioFiles: [ShortMinioFileDTO]
    
    private enum CodingKeys: String, CodingKey {
        case id, dateEnd, minioFiles
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let dateString = try container.decode(String.self, forKey: .dateEnd)
        dateEnd = dateFormatter.date(from: dateString) ?? Date()
        
        minioFiles = try container.decode([ShortMinioFileDTO].self, forKey: .minioFiles)
    }
}

struct ShortPassRequestDTO: Codable, Identifiable {
    let id: String
    let user: ShortUserDTO
    let dateStart: Date
    let dateEnd: Date
    let minioFiles: [ShortMinioFileDTO]
    let extendPassTimeRequests: [ShortExtendPassTimeRequestDTO]
    let isAccepted: Bool
    let createTimestamp: Date
    
    private enum CodingKeys: String, CodingKey {
        case id, user, dateStart, dateEnd, minioFiles, extendPassTimeRequests, isAccepted, createTimestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        user = try container.decode(ShortUserDTO.self, forKey: .user)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let dateStartString = try container.decode(String.self, forKey: .dateStart)
        dateStart = dateFormatter.date(from: dateStartString) ?? Date()
        
        let dateEndString = try container.decode(String.self, forKey: .dateEnd)
        dateEnd = dateFormatter.date(from: dateEndString) ?? Date()
        
        minioFiles = try container.decode([ShortMinioFileDTO].self, forKey: .minioFiles)
        extendPassTimeRequests = try container.decode([ShortExtendPassTimeRequestDTO].self, forKey: .extendPassTimeRequests)
        isAccepted = try container.decode(Bool.self, forKey: .isAccepted)
        
        let createTimestampString = try container.decode(String.self, forKey: .createTimestamp)
        createTimestamp = dateFormatter.date(from: createTimestampString) ?? Date()
    }
}

struct PageableObject: Codable {
    let offset: Int64
    let sort: SortObject
    let paged: Bool
    let pageNumber: Int32
    let pageSize: Int32
    let unpaged: Bool
}

struct SortObject: Codable {
    let empty: Bool
    let sorted: Bool
    let unsorted: Bool
}

struct PageableResponse<T: Codable>: Codable {
    let content: [T]
    let pageable: PageableObject
    let totalElements: Int64
    let totalPages: Int32
    let last: Bool
    let size: Int32
    let number: Int32
    let sort: SortObject
    let numberOfElements: Int32
    let first: Bool
    let empty: Bool
} 