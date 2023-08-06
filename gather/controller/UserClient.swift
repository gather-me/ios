import Foundation
import Combine
import SwiftUI

let gatewayEndoint = "http://164.90.185.210:8080/"

class UserClient {
    @ObservedObject private var accessTokenModel = AccessTokenModel.shared

    func register(user: User) -> AnyPublisher<URLResponse, Error> {
        let urlString = "\(gatewayEndoint)register"
        print(urlString)
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let token = "eyJraWQiOiIzMzdjMWZmYi03YjBiLTQ2ODYtOTU0Zi05NTUzN2FmNWEyY2MiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIxIiwiYXVkIjoibXktY2xpZW50LWlkIiwibmJmIjoxNjg2NTYxOTgyLCJpc3MiOiJodHRwOi8vMTY0LjkwLjE4NS4yMTA6OTAwMCIsImV4cCI6MTcxODA5Nzk4MiwiaWF0IjoxNjg2NTYxOTgyfQ.DLKgTEOd23sSixf45LGAwlt4eRr5auW3jHu-dtt-wzpJgkyI_DIOnY3Twk8ng_tF-DCOvoadRNTo2UdVduRuyNOSq_Dx_3gEo_Rqrar0AEFjrJn6Wdle70ergFV2K8E3f8t740SfAEq-oDY229yTZUsVvV9Jpp96hQy7WaJTeq_8E4bZbX7lH879ZtybGIlXAHue6gt6Xpqs_0Pw22a4vuf8QMCU--lQMTMjEk2Li6QFCAViGUpxbZriFTC3phYdirEFhIK_cNSUN8WPE4eYDGYRQiHGT29vwlrSyIwUi9EVa0D-YbB9OTUB1T5O97PWpqQV-SOFgGlHfaRED35AxQ"
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
            print(jsonData)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        print(response)
                        return response
                    } else {
                        // Request failed with a status code outside the success range
                        if let errorMessage = String(data: data, encoding: .utf8) {
                            // If the response payload includes an error message, throw a custom error
                            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        } else {
                            // If the response payload does not include an error message, throw a generic error
                            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Bad Request"])
                        }
                    }
                }
                throw URLError(.unknown)
            }
            .eraseToAnyPublisher()
    }
    
    
    func getUserById(userId: Int) -> AnyPublisher<UserModel, Error> {
        let urlString = "\(gatewayEndoint)users/\(userId)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: UserModel.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getFollowerCount(userId: Int) -> AnyPublisher<Int, Error> {
        let urlString = "\(gatewayEndoint)users/\(userId)/followers/count"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Int.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getFollowers(userId: Int) -> AnyPublisher<[UserModel], Error> {
        let urlString = "\(gatewayEndoint)users/\(userId)/followers"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [UserModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getFollowingCount(userId: Int) -> AnyPublisher<Int, Error> {
        let urlString = "\(gatewayEndoint)users/\(userId)/followings/count"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Int.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getFollowings(userId: Int) -> AnyPublisher<[UserModel], Error> {
        let urlString = "\(gatewayEndoint)users/\(userId)/followings"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [UserModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func follow(followingUserId: Int) -> AnyPublisher<Bool, Error> {
        let urlString = "\(gatewayEndoint)users/me/follow?followingUserId=\(followingUserId)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Bool.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

class UserViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var isFollowing: Bool?
    @Published var followings: [UserModel]?
    @Published var followingCount: Int?
    @Published var followers: [UserModel]?
    @Published var followerCount: Int?
    @Published var error: Error?
    @Published var invitations: [InvitationModel]?
    @Published var requests: [EnrollmentRequestModel]?
    @Published var previousEvents: [BaseEventModel]?
    @Published var recommendedEvents: [BaseEventModel]?
    @Published var createdEvents: [BaseEventModel]?
    @Published var unratedPreviousEvents: [BaseEventModel]?
    private var userCancellables = Set<AnyCancellable>()
    private var followCancellables = Set<AnyCancellable>()
    private var followingsCancellables = Set<AnyCancellable>()
    private var followingCountCancellables = Set<AnyCancellable>()
    private var followersCancellables = Set<AnyCancellable>()
    private var followerCountCancellables = Set<AnyCancellable>()
    private var unratedPreviousEventsCancellables = Set<AnyCancellable>()
    private var previousEventsCancellables = Set<AnyCancellable>()
    private var recommendedEventsCancellables = Set<AnyCancellable>()
    private var recommendationCancellables = Set<AnyCancellable>()
    private var groupRecommendationCancellables = Set<AnyCancellable>()
    private var invitationsCancellables = Set<AnyCancellable>()
    private var requestsCancellables = Set<AnyCancellable>()
    private var createdEventsCancellables = Set<AnyCancellable>()
    private let userClient = UserClient()
    private let eventClient = EventClient()
    private let recommendationClient = RecommendationClient()
    
    func fetchUserById(userId: Int) {
        userClient.getUserById(userId: userId)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                    print(error)
                }
            }, receiveValue: { [weak self] user in
                self?.user = user
            })
            .store(in: &userCancellables)
    }
    
    func fetchFollowings(userId: Int) {
        userClient.getFollowings(userId: userId)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                    print(error)
                }
            }, receiveValue: { [weak self] followings in
                self?.followings = followings
            })
            .store(in: &followingsCancellables)
    }
    
    func fetchFollowingCount(userId: Int) {
        userClient.getFollowingCount(userId: userId)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                    print(error)
                }
            }, receiveValue: { [weak self] count in
                self?.followingCount = count
            })
            .store(in: &followingCountCancellables)
    }
    
    func fetchFollowers(userId: Int, currentUserId: Int) {
        userClient.getFollowers(userId: userId)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                    print(error)
                }
            }, receiveValue: { [weak self] followers in
                self?.followers = followers
                self?.isFollowing = followers.contains { usr in
                    usr.id == currentUserId
                }
            })
            .store(in: &followersCancellables)
    }
    
    func fetchFollowerCount(userId: Int) {
        userClient.getFollowerCount(userId: userId)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                    print(error)
                }
            }, receiveValue: { [weak self] count in
                self?.followerCount = count
            })
            .store(in: &followerCountCancellables)
    }
    func fetchCreatedEvents(userId: Int, page: Int) {
        eventClient.getCreatedEvents(userId: userId, page:page)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                    print(error)
                }
            }, receiveValue: { [weak self] events in
                self?.createdEvents = events
            })
            .store(in: &createdEventsCancellables)
    }
    
    func fetchPreviousEvents(userId: Int, page: Int) {
        eventClient.getPreviousEvents(userId: userId, page:page)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                    print(error)
                }
            }, receiveValue: { [weak self] events in
                self?.previousEvents = events
            })
            .store(in: &previousEventsCancellables)
    }
    
    
    func follow(userId: Int, followingUserId: Int) {
        userClient.follow(followingUserId: followingUserId)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.fetchFollowers(userId: followingUserId, currentUserId: userId)
                    self?.fetchFollowerCount(userId: followingUserId)
                case .failure(let error):
                    print(error)
                    self?.error = error
                }
            }, receiveValue: { [weak self] follow in
                self?.isFollowing = follow
            })
            .store(in: &followCancellables)
    }
    
    func fetchInvitations(userId: Int) {
        eventClient.getInvitations(userId: userId)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                    self?.error = error
                }
            }, receiveValue: { [weak self] invitations in
                self?.invitations = invitations
            })
            .store(in: &invitationsCancellables)
    }
    
    func fetchRequests(userId: Int) {
        eventClient.getRequests(userId: userId)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                    self?.error = error
                }
            }, receiveValue: { [weak self] req in
                self?.requests = req
            })
            .store(in: &requestsCancellables)
    }

    func getRecommendation(userId: Int, eventType: EventType, completion: @escaping ([Int]) -> Void) {
        recommendationClient.getRecommendation(userId: userId, eventType: eventType)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                    self?.error = error
                }
            }, receiveValue: { recommendations in
                let sortedRecommendations = recommendations.sorted(by: { $0.prediction > $1.prediction })
                let eventIds = sortedRecommendations.map { $0.id }
                completion(eventIds)
            })
            .store(in: &recommendationCancellables)
    }
    
    func getGroupRecommendation(userId: Int, userIds: [Int], eventType: EventType, completion: @escaping ([Int]) -> Void) {
        recommendationClient.getGroupRecommendation(userId: userId, userIds: userIds, eventType: eventType)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                    self?.error = error
                }
            }, receiveValue: { recommendations in
                let sortedRecommendations = recommendations.sorted(by: { $0.prediction > $1.prediction })
                let eventIds = sortedRecommendations.map { $0.id }
                completion(eventIds)
            })
            .store(in: &groupRecommendationCancellables)
    }
    

}
