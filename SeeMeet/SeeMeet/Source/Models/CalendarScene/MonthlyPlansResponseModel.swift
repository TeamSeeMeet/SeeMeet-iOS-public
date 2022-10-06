import Foundation

// MARK: - Response
struct MonthlyPlansResponseModel: Codable {
    let status: Int
    let success: Bool?
    let data: [Plan]?
    let message: String?
}

// MARK: - Plan
struct Plan: Codable {
    let planID: Int
    let invitationTitle, date, start, end: String
    let users: [User]

    enum CodingKeys: String, CodingKey {
        case planID = "planId"
        case invitationTitle, date, start, end, users
    }
}

// MARK: - User
struct User: Codable {
    let userID: Int
    let username: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case username
    }
}

extension Plan: Equatable {
    static func == (lhs: Plan, rhs: Plan) -> Bool {
        lhs.planID == rhs.planID
    }
}
