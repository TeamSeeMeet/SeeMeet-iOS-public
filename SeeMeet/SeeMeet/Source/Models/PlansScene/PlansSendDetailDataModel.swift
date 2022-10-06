import Foundation

// MARK: - PlansDetailDataModel
struct PlansSendDetailDataModel: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: PlansSendDetailData
}

// MARK: - PlansSendDetailData
struct PlansSendDetailData: Codable {
    let invitation: PlansSendInvitation
    let invitationDates: [PlansSendInvitationDate]
}

// MARK: - Invitation
struct PlansSendInvitation: Codable {
    let id, hostID: Int
    let invitationTitle, invitationDesc: String
    let isConfirmed, isCanceled: Bool
    let createdAt: String
    let isDeleted: Bool
    let host: Host
    let guests: [SendGuest]

    enum CodingKeys: String, CodingKey {
        case id
        case hostID = "host_id"
        case invitationTitle = "invitation_title"
        case invitationDesc = "invitation_desc"
        case isConfirmed = "is_confirmed"
        case isCanceled = "is_canceled"
        case createdAt = "created_at"
        case isDeleted = "is_deleted"
        case host, guests
    }
}

// MARK: - Guest
struct SendGuest: Codable {
    let id: Int
    let username: String
    let isResponse: Bool
}

// MARK: - InvitationDate
struct PlansSendInvitationDate: Codable {
    let id, invitationID: Int
    let date, start, end: String
    let respondent: [Host]

    enum CodingKeys: String, CodingKey {
        case id
        case invitationID = "invitation_id"
        case date, start, end, respondent
    }
}
