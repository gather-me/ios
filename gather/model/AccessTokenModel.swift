import Combine

class AccessTokenModel: ObservableObject {
    @Published var accessToken: String?
    @Published var currentUserId: Int?
    static let shared = AccessTokenModel()
    
    private init() {}
}
