import Foundation

struct GroupDTO: Codable, Identifiable {
    let groupNumber: Int
    let isDeleted: Bool
    
    var id: Int { groupNumber }
}

struct GroupListResponse: Decodable {
    let groups: [GroupDTO]
} 