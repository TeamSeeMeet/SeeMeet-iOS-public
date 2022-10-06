//
//  ProfileImageResponseModel.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/06/30.
//

import Foundation

// MARK: - Main
struct ProfileImageResponseModel: Codable {
    let status: Int
    let success: Bool
    let data: ProfileImageResponseData?
    let message: String?
}

// MARK: - DataClass
struct ProfileImageResponseData: Codable {
    let id: Int
    let email, idFirebase, username: String
    let isNoticed: Bool
    let createdAt, updatedAt: String
    let isDeleted: Bool
    let provider: String
    let socialID: String?
    let nickname: String
    let imgLink: String
    let push: Bool
    let password: String?
    let imgName: String

    enum CodingKeys: String, CodingKey {
        case id, email, idFirebase, username, isNoticed, createdAt, updatedAt, isDeleted, provider
        case socialID = "socialId"
        case nickname, imgLink, push, password, imgName
    }
}
