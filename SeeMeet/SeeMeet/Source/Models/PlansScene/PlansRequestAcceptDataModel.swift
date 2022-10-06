// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let plansDetailDataModel = try? newJSONDecoder().decode(PlansDetailDataModel.self, from: jsonData)

import Foundation

// MARK: - PlansDetailDataModel
struct PlansRequestAcceptDataModel: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: PlansRequestAcceptData
}

// MARK: - PlansRequestAcceptData
struct PlansRequestAcceptData: Codable {
    let invitation: PlansRequestAcceptInvitation
    let invitationDate: PlansRequestAcceptInvitationDate
    let plan: Plan
}

// MARK: - Invitation
struct PlansRequestAcceptInvitation: Codable {
    let id, hostID: Int
    let invitationTitle, invitationDesc: String
    let isConfirmed, isCanceled: Bool
    let createdAt: String
    let isDeleted: Bool
    let host: Host

    enum CodingKeys: String, CodingKey {
        case id
        case hostID = "host_id"
        case invitationTitle = "invitation_title"
        case invitationDesc = "invitation_desc"
        case isConfirmed = "is_confirmed"
        case isCanceled = "is_canceled"
        case createdAt = "created_at"
        case isDeleted = "is_deleted"
        case host
    }
}

// MARK: - InvitationDate
struct PlansRequestAcceptInvitationDate: Codable {
    let id, invitationID: Int
    let date, start, end: String
    let guest: [SendGuest]?

    enum CodingKeys: String, CodingKey {
        case id
        case invitationID = "invitation_id"
        case date, start, end, guest
    }
}

// MARK: - Plan
struct RequestAcceptPlan: Codable {
    let id, invitationDateID: Int
    let createdAt: String
    let isDeleted: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case invitationDateID = "invitation_date_id"
        case createdAt = "created_at"
        case isDeleted = "is_deleted"
    }
}

