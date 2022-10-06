//
//  CanceledPlanDetailModel.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/08/13.
//

import Foundation

// MARK: - Main
struct CanceledPlanDetailModel: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: canceledData
}

// MARK: - DataClass
struct canceledData: Codable {
    let id, hostID: Int
    let invitationTitle, invitationDesc: String
    let isConfirmed, isCanceled: Bool
    let createdAt: String
    let isDeleted: Bool
    let canceledAt: String
    let isVisible: Bool
    let hostName: String
    let guest: [CanceledPlansGuest]

    enum CodingKeys: String, CodingKey {
        case id
        case hostID = "hostId"
        case invitationTitle, invitationDesc, isConfirmed, isCanceled, createdAt, isDeleted, canceledAt, isVisible, hostName, guest
    }
}

// MARK: - Guest
struct CanceledPlansGuest: Codable {
    let id: Int
    let username: String
}
