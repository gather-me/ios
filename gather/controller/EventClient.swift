import Foundation
import Combine
import SwiftUI


class EventClient {
    @ObservedObject private var accessTokenModel = AccessTokenModel.shared
    var cancellables = Set<AnyCancellable>()
    
    func rate(eventType: EventType, eventId: Int, userId: Int, rate: Int) -> AnyPublisher<URLResponse, Error> {
        let urlString = "\(gatewayEndoint)users/me/events/\(eventType)/\(eventId)/rate?rate=\(rate)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
    
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        // Request succeeded, return the response
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
    func createEvent(userId: Int, body: EventCreationModel) -> AnyPublisher<URLResponse, Error> {
        let urlString = "\(gatewayEndoint)users/me/events/\(body.eventType)/create"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        // Request succeeded, return the response
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
    
    func getUpcomingEvents(page: Int) -> AnyPublisher<[BaseEventModel], Error> {
        let urlString = "\(gatewayEndoint)events/upcoming?page=\(page)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [BaseEventModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getFollowingEvents(userId:Int, page: Int) -> AnyPublisher<[BaseEventModel], Error> {
        let urlString = "\(gatewayEndoint)users/me/events/followings?page=\(page)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [BaseEventModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getCreatedEvents(userId: Int, page: Int) -> AnyPublisher<[BaseEventModel], Error> {
        let urlString = "\(gatewayEndoint)users/\(userId)/events/created-events?page=\(page)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [BaseEventModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getInvitations(userId: Int) -> AnyPublisher<[InvitationModel], Error> {
        let urlString = "\(gatewayEndoint)users/me/events/invitations"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [InvitationModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getRequests(userId: Int) -> AnyPublisher<[EnrollmentRequestModel], Error> {
        let urlString = "\(gatewayEndoint)users/me/events/created-events/requests"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [EnrollmentRequestModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getPreviousEvents(userId: Int, page: Int) -> AnyPublisher<[BaseEventModel], Error> {
        let urlString = "\(gatewayEndoint)users/\(userId)/events/previous?page=\(page)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [BaseEventModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getUnratedEvents(userId: Int, page: Int) -> AnyPublisher<[BaseEventModel], Error> {
        let urlString = "\(gatewayEndoint)users/me/events/previous/unrated?page=\(page)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [BaseEventModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getEvent(eventId: Int, eventType: EventType) -> AnyPublisher<EventModel, Error> {
        let urlString = "\(gatewayEndoint)events/\(eventType)/\(eventId)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: EventModel.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getEvents(eventIds: [Int], eventType: EventType) -> AnyPublisher<[BaseEventModel], Error> {
        let eventIdsQuery = eventIds.map { "ids=\($0)" }.joined(separator: "&")
        let urlString = "\(gatewayEndoint)events/\(eventType)?\(eventIdsQuery)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [BaseEventModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getInvitingUsers(eventType: EventType, eventId: Int, page: Int) -> AnyPublisher<[UserModel], Error> {
        let urlString = "\(gatewayEndoint)events/\(eventType)/\(eventId)/inviting?page=\(page)"
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
    
    func getEventParticipants(eventType: EventType, eventId: Int, enrolled: Bool) -> AnyPublisher<[UserModel], Error> {
        let urlString = "\(gatewayEndoint)events/\(eventType)/\(eventId)/participants?enrolled=\(enrolled)"
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
    func invite(currUserId: Int, eventType: EventType, eventId: Int, userId: Int) -> AnyPublisher<URLResponse, Error> {
        let urlString = "\(gatewayEndoint)users/me/events/\(eventType)/\(eventId)/invite?invitedUserId=\(userId)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        // Request succeeded, return the response
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
    
    func enroll(eventType: EventType, eventId: Int, userId: Int) -> AnyPublisher<URLResponse, Error> {
        let urlString = "\(gatewayEndoint)users/me/enroll/events/\(eventType)/\(eventId)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        // Request succeeded, return the response
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
    func respond(eventType: EventType, invitationId: Int, userId: Int, response: Bool) -> AnyPublisher<URLResponse, Error> {
        let urlString = "\(gatewayEndoint)users/me/invitations/\(eventType)/\(invitationId)/respond?response=\(response)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        // Request succeeded, return the response
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
    func respondEnrollmentRequest(creatorId: Int, eventId: Int, userId: Int, eventType: EventType, response: Bool) -> AnyPublisher<URLResponse, Error> {
        let urlString = "\(gatewayEndoint)users/me/events/\(eventType)/\(eventId)/enrollment-requests/\(userId)?response=\(response)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessTokenModel.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        // Request succeeded, return the response
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
}


class EventViewModel: ObservableObject {
    @Published var event: EventModel
    @Published var participants: [UserModel]?
    @Published var invitingUsers: [UserModel]?
    @Published var requesters: [UserModel]?
    @Published var error: Error?
    private var eventCancellables = Set<AnyCancellable>()
    private var participantsCancellables = Set<AnyCancellable>()
    private var invitingUsersCancellables = Set<AnyCancellable>()
    private var requestersCancellables = Set<AnyCancellable>()
    private var enrollmentCancellables = Set<AnyCancellable>()
    private var respondCancellables = Set<AnyCancellable>()
    private let userClient = UserClient()
    private let eventClient = EventClient()
    
    init(event: EventModel = EventModel(
        id: -1,
        eventType: .sport,
        title: "",
        description: nil,
        creator: UserModel(id: -1, firstName: "", secondName: "", username: "", emailAddress: ""),
        capacity: nil,
        enrolled: -1,
        price: nil,
        isPrivate: true,
        category: SportCategory.football.rawValue,
        startDate: "",
        endDate: "",
        locationModel: LocationModel(latitude: 0, longitude: 0),
        artist: nil
    )) {
        self.event = event
    }
    
    
    func fetchEventByIdAndType(eventId: Int, eventType: EventType) {
        eventClient.getEvent(eventId: eventId, eventType: eventType)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("error on fetchEventByIdAndType")
                    print(error)
                    self?.error = error
                }
            }, receiveValue: { [weak self] event in
                self?.event = event
            })
            .store(in: &eventCancellables)
    }
    
    func fetchInvitingUsers(eventId: Int, eventType: EventType, page: Int) {
        eventClient.getInvitingUsers(eventType: eventType, eventId: eventId, page: page)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                    print("error on fetchInvitingUsers 1")
                    print(error)
                }
            }, receiveValue: { [weak self] participants in
                self?.invitingUsers = participants
            })
            .store(in: &invitingUsersCancellables)
        
        eventClient.getEventParticipants(eventType: eventType, eventId: eventId, enrolled: false)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                    print("error on fetchInvitingUsers 2")
                    print(error)
                }
            }, receiveValue: { [weak self] participants in
                self?.requesters = participants
            })
            .store(in: &requestersCancellables)
    }
    
    func fetchParticipants(eventId: Int, eventType: EventType, currUserId: Int) {
        eventClient.getEventParticipants(eventType: eventType, eventId: eventId, enrolled: true)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                    print("error on fetchParticipants 1")
                    print(error)
                }
            }, receiveValue: { [weak self] participants in
                self?.participants = participants
            })
            .store(in: &participantsCancellables)
        
        eventClient.getEventParticipants(eventType: eventType, eventId: eventId, enrolled: false)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("error on fetchParticipants 2")
                    print(error)
                    self?.error = error
                }
            }, receiveValue: { [weak self] participants in
                self?.requesters = participants
            })
            .store(in: &requestersCancellables)
    }
    
    func enroll(eventId: Int, eventType: EventType, userId:Int){
        eventClient.enroll(eventType: eventType, eventId: eventId, userId: userId)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.fetchEventByIdAndType(eventId: eventId, eventType: eventType)
                    self?.fetchParticipants(eventId: eventId, eventType: eventType, currUserId: userId)
                    break
                case .failure(let error):
                    print("error on enroll")
                    print(error)
                    self?.error = error
                }
            }, receiveValue: {_ in })
            .store(in: &enrollmentCancellables)
    }
    
    func respond(eventId: Int, invitationId: Int, eventType: EventType, userId:Int, response: Bool, action: @escaping ()-> Void){
        eventClient.respond(eventType: eventType, invitationId: invitationId, userId: userId, response: response)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.fetchEventByIdAndType(eventId: eventId, eventType: eventType)
                    self?.fetchParticipants(eventId: eventId, eventType: eventType, currUserId: userId)
                    action()
                    break
                case .failure(let error):
                    print("error on respond")
                    print(error)
                    self?.error = error
                }
            }, receiveValue: {_ in })
            .store(in: &respondCancellables)
    }
}
