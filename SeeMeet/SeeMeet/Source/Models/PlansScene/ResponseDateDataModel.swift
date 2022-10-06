import Foundation

// MARK: - PlansDetailDataModel
struct ResponseDateDataModel: Codable {
    let status: Int
    let success: Bool
    let data: [ResponseDateData]
}

// MARK: - Datum
struct ResponseDateData: Codable {
    let invitationTitle, date, start, end: String
    let planid: Int
    let users: [ResponseUser]
}

// MARK: - User
struct ResponseUser: Codable {
    let userID: Int
    let username: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case username
    }
}
