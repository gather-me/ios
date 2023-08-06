import Foundation

struct EventCreationModel: Codable{
    let eventType: EventType

    let title: String

    let description: String?

    let capacity: Int?

    let price: Double?

    let isPrivate: Bool

    let category: String

    let startDate: String

    let endDate: String

    let locationModel: LocationModel
    
    let artist: String?
}
