import Foundation

struct ToDoModel: Identifiable, Codable {
    var id: Int?
    var createdAt: Date
    var title: String
    var isComplete: Bool
    let userId: UUID
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case createdAt = "created_at"
        case isComplete = "is_complete"
        case userId = "user_id"
    }

}

