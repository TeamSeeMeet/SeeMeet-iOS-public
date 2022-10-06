// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let plansDetailDataModel = try? newJSONDecoder().decode(PlansDetailDataModel.self, from: jsonData)

import Foundation

// MARK: - PlansDetailDataModel
struct InvitationListCancelDataModel: Codable {
    let status: Int
    let success: Bool
    let message: String?
}
