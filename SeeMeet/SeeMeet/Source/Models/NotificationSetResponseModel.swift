//
//  NotificationSetResponseModel.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/08/11.
//

import Foundation

// MARK: - Welcome
struct NotificationSetResponseModel: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: NotificationSetData
}

// MARK: - DataClass
struct NotificationSetData: Codable {
    let id: Int
    let email: String?
    let idFirebase, username: String?
    let isNoticed: Bool
    let createdAt, updatedAt: String
    let isDeleted: Bool
    let provider: String
    let socialID, nickname, imgLink: String?
    let push: Bool
    let password: String?
    let imgName, fcm: String?

    enum CodingKeys: String, CodingKey {
        case id, email, idFirebase, username, isNoticed, createdAt, updatedAt, isDeleted, provider
        case socialID = "socialId"
        case nickname, imgLink, push, password, imgName, fcm
    }
}
