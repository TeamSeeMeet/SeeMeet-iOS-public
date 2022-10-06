import Foundation

// MARK: - RegisterModel
struct RegisterDataModel: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: RegisterData?
}

// MARK: - RegisterData
struct RegisterData: Codable {
    let newUser: NewUser
    let accesstoken: String
    let refreshtoken: String
}

// MARK: - User
struct NewUser: Codable {
    let id: Int
    let email: String
    let idFirebase, username: String?
    let isNoticed: Bool
    let createdAt, updatedAt: String
    let isDeleted: Bool
    let provider: String
    let socialId, nickname, imgLink: String?
    let push: Bool
    let password: String
    let imgName, fcm, refreshToken: String?
    
}
