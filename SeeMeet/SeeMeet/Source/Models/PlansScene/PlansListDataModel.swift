// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let homeDataModel = try? newJSONDecoder().decode(HomeDataModel.self, from: jsonData)

import Foundation

// MARK: - HomeDataModel
struct PlansListDataModel: Codable {
    let status: Int
    let success: Bool?
    let data: PlansListData?
    let message: String?
}

// MARK: - PlansListData
struct PlansListData: Codable {
    let invitations: [Invitation]
    let confirmedAndCanceld: [ConfirmedAndCanceld]
}

// MARK: - ConfirmedAndCanceld
struct ConfirmedAndCanceld: Codable {
    let id: Int
    let invitationTitle: String
    let isCanceled, isConfirmed: Bool
    let guests: [Guest]
    let planID: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case invitationTitle = "invitation_title"
        case isCanceled = "is_canceled"
        case isConfirmed = "is_confirmed"
        case guests
        case planID = "planId"
    }
}

// MARK: - Guest
struct Guest: Codable {
    let id: Int
    let username: String
//    let impossible: Bool?
    let isResponse: Bool?
}

// MARK: - Invitation
struct Invitation: Codable {
    let id: Int
    let hostID: Int?
    let invitationTitle, invitationDesc: String
    let isConfirmed, isCanceled: Bool
    let createdAt: String
    let isDeleted: Bool
    let guests: [Guest]?
    let isReceived, isResponse: Bool
    let host: Host?
    let canceled_at: String?
    let days: Int
    let isVisible: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case hostID = "host_id"
        case invitationTitle = "invitation_title"
        case invitationDesc = "invitation_desc"
        case isConfirmed = "is_confirmed"
        case isCanceled = "is_canceled"
        case createdAt = "created_at"
        case isDeleted = "is_deleted"
        case isVisible = "is_visible"
        case guests, isReceived, isResponse, host, canceled_at, days
    }
}

// MARK: - Host
struct Host: Codable {
    let id: Int
    let username: String?
}
