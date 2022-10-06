// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let plansDetailDataModel = try? newJSONDecoder().decode(PlansDetailDataModel.self, from: jsonData)

import Foundation

// MARK: - PlansDetailDataModel
struct InvitationCancelDataModel: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: InvitationCancelData
}

// MARK: - InvitationCancelData
struct InvitationCancelData: Codable {
    let invitation: [InvitationCancel]
}

// MARK: - Invitation
struct InvitationCancel: Codable {
    let invitationID, hostID: Int
    let invitationTitle, invitationDesc: String
    let isConfirmed, isCanceled: Bool
    let createdAt: String
    let isDeleted: Bool

    enum CodingKeys: String, CodingKey {
        case invitationID = "invitationId"
        case hostID = "hostId"
        case invitationTitle, invitationDesc, isConfirmed, isCanceled, createdAt, isDeleted
    }
}
