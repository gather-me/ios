import Foundation

struct UserModel: Codable, Identifiable, Hashable {
    let id: Int
    let firstName: String
    let secondName: String
    let username: String
    let emailAddress: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.id == rhs.id
    }
}

