import Foundation

enum EventType: String, CaseIterable, Codable {
    case musical = "Musical"
    case nature = "Nature"
    case sport = "Sport"
    case stagePlay = "StagePlay"
}

enum MusicalCategory: String, CaseIterable, Codable {
    case concert = "Concert"
    case festival = "Festival"
}

enum SportCategory: String, CaseIterable, Codable {
    case basketball = "Basketball"
    case football = "Football"
    case volleyball = "Volleyball"
    case jogging = "Jogging"
}

enum NatureCategory: String, CaseIterable, Codable {
    case hiking = "Hiking"
    case camp = "Camp"
}

enum StagePlayCategory: String, CaseIterable, Codable {
    case standUp = "StandUp"
    case theatre = "Theatre"
}
