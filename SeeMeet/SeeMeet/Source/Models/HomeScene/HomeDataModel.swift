import Foundation

// MARK: - HomeDataModel
struct HomeDataModel: Codable {
    let status: Int
    let success: Bool
    let data: [HomeData]
}

// MARK: - Datum
struct HomeData: Codable {
    let planID: Int
    let invitationTitle, date, count: String

    enum CodingKeys: String, CodingKey {
        case planID = "planId"
        case invitationTitle, date, count
    }
}
