// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let plansDetailDataModel = try? newJSONDecoder().decode(PlansDetailDataModel.self, from: jsonData)

import Foundation

// MARK: - PlansDetailDataModel
struct InvitationPlansDataModel: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [InvitationPlansData]
}

// MARK: - Datum
struct InvitationPlansData: Codable {
    let responseID: Int
    let invitationDate: InvitationDate

    enum CodingKeys: String, CodingKey {
        case responseID = "responseId"
        case invitationDate
    }
}

// MARK: - InvitationDate
struct InvitationDate: Codable {
    let id, invitationID: Int
    let date, start, end: String

    enum CodingKeys: String, CodingKey {
        case id
        case invitationID = "invitation_id"
        case date, start, end
    }
}
