import Foundation

// MARK: - Response
struct FriendsSearchResponseModel: Codable {
    let status: Int
    let success: Bool?
    let message: String?
    let data: FriendData?
}

// MARK: - FriendData
struct FriendData: Codable {
    let id: Int
    let email, idFirebase, username: String?
    let isNoticed: Bool
    let createdAt, updatedAt: String
    let isDeleted: Bool
    let provider, socialId: String?
    let nickname: String
}
