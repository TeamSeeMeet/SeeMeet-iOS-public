import Foundation

// MARK: - FriendsAddResponseModel
struct FriendsAddResponseModel: Codable {
    let status: Int
    let success: Bool?
    let message: String?
    let data: AddInfo?
}

// MARK: - AddInfo
struct AddInfo: Codable {
    let id, sender, receiver: Int
    let isDeleted: Bool
    let updatedAt: String
    let receiverDeleted: Bool
}
