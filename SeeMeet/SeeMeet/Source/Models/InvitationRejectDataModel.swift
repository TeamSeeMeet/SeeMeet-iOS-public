import Foundation

// MARK: - PlansDetailDataModel
struct InvitationRejectDataModel: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: InvitationReject
}

// MARK: - InvitationReject
struct InvitationReject: Codable {
    let id, invitationID: Int
        let impossible: Bool

        enum CodingKeys: String, CodingKey {
            case id
            case invitationID = "invitationId"
            case impossible
        }
}
