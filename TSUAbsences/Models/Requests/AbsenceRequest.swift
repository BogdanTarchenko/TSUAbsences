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

struct ShortExtendPassTimeRequestDTO: Codable, Identifiable {
    let id: String
    let dateEnd: Date
    let minioFiles: [ShortMinioFileDTO]
    let isAccepted: Bool?
    let createTimestamp: Date
    let message: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case dateEnd
        case minioFiles
        case isAccepted
        case createTimestamp
        case message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let dateEndString = try container.decode(String.self, forKey: .dateEnd)
        if let date = dateFormatter.date(from: dateEndString) {
            dateEnd = date
        } else {
            let simpleFormatter = ISO8601DateFormatter()
            if let date = simpleFormatter.date(from: dateEndString) {
                dateEnd = date
            } else {
                dateEnd = Date()
            }
        }
        
        minioFiles = try container.decode([ShortMinioFileDTO].self, forKey: .minioFiles)
        isAccepted = try container.decodeIfPresent(Bool.self, forKey: .isAccepted)
        
        let createTimestampString = try container.decode(String.self, forKey: .createTimestamp)
        if let date = dateFormatter.date(from: createTimestampString) {
            createTimestamp = date
        } else {
            let simpleFormatter = ISO8601DateFormatter()
            createTimestamp = simpleFormatter.date(from: createTimestampString) ?? Date()
        }
        
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
}

struct ShortPassRequestDTO: Codable, Identifiable {
    let id: String
    let user: ShortUserDTO
    let dateStart: Date
    let dateEnd: Date
    let minioFiles: [ShortMinioFileDTO]
    let extendPassTimeRequests: [ShortExtendPassTimeRequestDTO]
    let isAccepted: Bool?
    let createTimestamp: Date
    let message: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, user, dateStart, dateEnd, minioFiles, extendPassTimeRequests, isAccepted, createTimestamp, message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        user = try container.decode(ShortUserDTO.self, forKey: .user)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let dateStartString = try container.decode(String.self, forKey: .dateStart)
        if let date = dateFormatter.date(from: dateStartString) {
            dateStart = date
        } else {
            let simpleFormatter = ISO8601DateFormatter()
            if let date = simpleFormatter.date(from: dateStartString) {
                dateStart = date
            } else {
                dateStart = Date()
            }
        }
        
        let dateEndString = try container.decode(String.self, forKey: .dateEnd)
        if let date = dateFormatter.date(from: dateEndString) {
            dateEnd = date
        } else {
            let simpleFormatter = ISO8601DateFormatter()
            if let date = simpleFormatter.date(from: dateEndString) {
                dateEnd = date
            } else {
                dateEnd = Date()
            }
        }
        
        minioFiles = try container.decode([ShortMinioFileDTO].self, forKey: .minioFiles)
        extendPassTimeRequests = try container.decode([ShortExtendPassTimeRequestDTO].self, forKey: .extendPassTimeRequests)
        isAccepted = try container.decodeIfPresent(Bool.self, forKey: .isAccepted)
        
        let createTimestampString = try container.decode(String.self, forKey: .createTimestamp)
        if let date = dateFormatter.date(from: createTimestampString) {
            createTimestamp = date
        } else {
            let simpleFormatter = ISO8601DateFormatter()
            createTimestamp = simpleFormatter.date(from: createTimestampString) ?? Date()
        }
        
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
    
    init(id: String, user: ShortUserDTO, dateStart: Date, dateEnd: Date, minioFiles: [ShortMinioFileDTO], extendPassTimeRequests: [ShortExtendPassTimeRequestDTO], isAccepted: Bool?, createTimestamp: Date, message: String?) {
        self.id = id
        self.user = user
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.minioFiles = minioFiles
        self.extendPassTimeRequests = extendPassTimeRequests
        self.isAccepted = isAccepted
        self.createTimestamp = createTimestamp
        self.message = message
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
