import Foundation

// MARK: - SocialLoginDataModel
struct SocialLoginDataModel: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: SocialLoginResponseData?
}

// MARK: - SocialLoginResponseData
struct SocialLoginResponseData: Codable {
    let user: socialUser
    let accesstoken: String
    let refreshtoken: String
}

// MARK: - socialUser
struct socialUser: Codable {
    let id: Int
    let email, idFirebase: String?
    let username: String
    let isNoticed: Bool
    let createdAt, updatedAt: String
    let isDeleted: Bool
    let provider, socialID: String
    let nickname: String?
    let imgLink: String?
    let push: Bool
    let password, imgName: String?
//    let fcm: String
    
    enum CodingKeys: String, CodingKey {
        case id, email, idFirebase, username, isNoticed, createdAt, updatedAt, isDeleted, provider
        case socialID = "socialId"
        case nickname, imgLink, push, password, imgName
    }
}
