import Foundation

struct UserDTO: Codable {
    let id: String
    let email: String
    let fullName: String
    let group: GroupDTO?
    let role: UserRole
    let isBlocked: Bool
}

struct MinioFileDTO: Codable {
    let id: String
    let uploadTime: Date
    let name: String
    let size: Int64
    
    private enum CodingKeys: String, CodingKey {
        case id, uploadTime, name, size
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let uploadTimeString = try container.decode(String.self, forKey: .uploadTime)
        uploadTime = dateFormatter.date(from: uploadTimeString) ?? Date()
        
        name = try container.decode(String.self, forKey: .name)
        size = try container.decode(Int64.self, forKey: .size)
    }
}

struct ExtendPassTimeRequestDTO: Codable {
    let id: String
    let passRequestId: String
    let dateEnd: Date
    let minioFiles: [MinioFileDTO]
    let isAccepted: Bool?
    let createTimestamp: Date
    let updateTimestamp: Date
    let message: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, passRequestId, dateEnd, minioFiles, isAccepted, createTimestamp, updateTimestamp, message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        passRequestId = try container.decode(String.self, forKey: .passRequestId)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let dateEndString = try container.decode(String.self, forKey: .dateEnd)
        dateEnd = dateFormatter.date(from: dateEndString) ?? Date()
        
        minioFiles = try container.decode([MinioFileDTO].self, forKey: .minioFiles)
        isAccepted = try container.decodeIfPresent(Bool.self, forKey: .isAccepted)
        
        let createTimestampString = try container.decode(String.self, forKey: .createTimestamp)
        createTimestamp = dateFormatter.date(from: createTimestampString) ?? Date()
        
        let updateTimestampString = try container.decode(String.self, forKey: .updateTimestamp)
        updateTimestamp = dateFormatter.date(from: updateTimestampString) ?? Date()
        
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
}

struct PassRequestDTO: Codable, Identifiable {
    let id: String
    let user: UserDTO
    let dateStart: Date
    let dateEnd: Date
    let minioFiles: [MinioFileDTO]
    let extendPassTimeRequests: [ExtendPassTimeRequestDTO]
    let isAccepted: Bool?
    let createTimestamp: Date
    let updateTimestamp: Date
    let message: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, user, dateStart, dateEnd, minioFiles, extendPassTimeRequests, isAccepted, createTimestamp, updateTimestamp, message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        user = try container.decode(UserDTO.self, forKey: .user)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let dateStartString = try container.decode(String.self, forKey: .dateStart)
        dateStart = dateFormatter.date(from: dateStartString) ?? Date()
        
        let dateEndString = try container.decode(String.self, forKey: .dateEnd)
        dateEnd = dateFormatter.date(from: dateEndString) ?? Date()
        
        minioFiles = try container.decode([MinioFileDTO].self, forKey: .minioFiles)
        extendPassTimeRequests = try container.decode([ExtendPassTimeRequestDTO].self, forKey: .extendPassTimeRequests)
        isAccepted = try container.decodeIfPresent(Bool.self, forKey: .isAccepted)
        
        let createTimestampString = try container.decode(String.self, forKey: .createTimestamp)
        createTimestamp = dateFormatter.date(from: createTimestampString) ?? Date()
        
        let updateTimestampString = try container.decode(String.self, forKey: .updateTimestamp)
        updateTimestamp = dateFormatter.date(from: updateTimestampString) ?? Date()
        
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
} 
