import Foundation


struct RecommendationModel: Codable {
    let id: Int
    
    let event_type: EventType
    
    let prediction: Float
}
