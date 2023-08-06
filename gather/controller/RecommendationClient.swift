import Foundation
import Combine
import SwiftUI


class RecommendationClient {
    @ObservedObject private var accessTokenModel = AccessTokenModel.shared

    func getRecommendation(userId: Int, eventType: EventType) -> AnyPublisher<[RecommendationModel], Error> {
        let urlString = "\(gatewayEndoint)users/me/recommend/events/\(eventType.rawValue)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .tryMap { data -> Data in
                return data
            }
            .decode(type: [RecommendationModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func getGroupRecommendation(userId: Int, userIds: [Int], eventType: EventType) -> AnyPublisher<[RecommendationModel], Error> {
        let userIdsQuery = userIds.map { "users=\($0)" }.joined(separator: "&")
        let urlString = "\(gatewayEndoint)users/me/recommend/events/\(eventType.rawValue)/group?\(userIdsQuery)"
            
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [RecommendationModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
