//
//  PutPasswordResponseModel.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/07/02.
//

import Foundation

// MARK: - Main
struct PasswordResponseModel: Codable {
    let status: Int
    let success: Bool?
    let message: String?
    let data : PasswordResponseData? 
}

// MARK: - Datum
struct PasswordResponseData: Codable {
    let id: Int
    let email, idFirebase: String?
    let username: String
    let isNoticed: Bool
    let createdAt, updatedAt: String
    let isDeleted: Bool
    let provider: String
    let socialID: String?
    let nickname: String
    let imgLink: String?
    let push: Bool
    let password: String
    let imgName,fcm: String?

    enum CodingKeys: String, CodingKey {
        case id, email
        case idFirebase = "id_firebase"
        case username
        case isNoticed = "is_noticed"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isDeleted = "is_deleted"
        case provider
        case socialID = "social_id"
        case nickname
        case imgLink = "img_link"
        case push, password
        case imgName = "img_name"
        case fcm
    }
}
