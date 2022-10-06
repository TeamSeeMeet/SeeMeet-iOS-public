import Foundation

// MARK: - WithdrawalDataModel
struct WithdrawalDataModel: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: WithdrawalResponseData?
}

// MARK: - WithdrawalResponseData
struct WithdrawalResponseData: Codable {
    let id: Int
    let email, idFirebase: String?
    let username: String
    let isNoticed: Bool
    let createdAt, updatedAt: String
    let isDeleted: Bool
    let provider: String
    let socialId, nickname: String?
    let imgLink: String?
    let push: Bool
    let password: String?
    let imgName: String?
    let fcm: String?
}
