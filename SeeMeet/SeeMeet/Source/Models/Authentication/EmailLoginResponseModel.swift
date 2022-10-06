//
//  EmailLoginResponseModel.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/08/06.
//

import Foundation

// MARK: - Main
struct EmailLoginResponseModel: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: EmailLoginData?
}

// MARK: - DataClass
struct EmailLoginData: Codable {
    let user: UserData
    let accesstoken: String
    let refreshtoken: String
}

// MARK: - User
struct UserData: Codable {
    let id: Int
    let email: String
    let idFirebase: String?
    let username: String?
    let isNoticed: Bool
    let createdAt, updatedAt: String
    let isDeleted: Bool
    let provider: String
    let socialID: String?
    let nickname: String?
    let imgLink: String?
    let push: Bool
    let password: String
    let imgName, fcm: String?

    enum CodingKeys: String, CodingKey {
        case id, email
        case idFirebase
        case username
        case isNoticed
        case createdAt
        case updatedAt
        case isDeleted
        case provider
        case socialID
        case nickname
        case imgLink
        case push, password
        case imgName
        case fcm
    }
}
