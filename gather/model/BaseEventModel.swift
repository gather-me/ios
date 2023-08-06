import Foundation

struct EventModel: Codable, Identifiable, Equatable {
    static func == (lhs: EventModel, rhs: EventModel) -> Bool {
        return lhs.id == rhs.id && lhs.eventType == rhs.eventType
    }
    
    let id: Int
    
    let eventType: EventType
    
    let title: String
    
    let description: String?
    
    let creator: UserModel
    
    let capacity: Int?
    
    let enrolled: Int
    
    let price: Double?
    
    let isPrivate: Bool
    
    let category: String
    
    let startDate: String
    
    let endDate: String
    
    let locationModel: LocationModel
    
    let artist: String?
    
    var identifier: String {
        return "\(id)-\(eventType)"
    }
}

struct BaseEventModel: Codable, Identifiable, Equatable{
    static func == (lhs: BaseEventModel, rhs: BaseEventModel) -> Bool {
        return lhs.id == rhs.id && lhs.eventType == rhs.eventType
    }
    
    let id: Int
    
    let eventType: EventType
    
    let title: String
    
    let description: String?
    
    let creator: UserModel
    
    let capacity: Int?
    
    let enrolled: Int
    
    let price: Double?
    
    let isPrivate: Bool
    
    let startDate: String
    
    let endDate: String
    
    let locationModel: LocationModel
    
    var identifier: String {
        return "\(id)-\(eventType)"
    }
}

struct EnrollmentRequestModel: Codable, Identifiable{
    let id: Int?
    
    let event: BaseEventModel
    
    let users: [UserModel]
}

struct InvitationModel:Codable , Identifiable, Equatable{
    static func == (lhs: InvitationModel, rhs: InvitationModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int
    
    let event: BaseEventModel
    
    let user: UserModel
    
    let date: String
}
