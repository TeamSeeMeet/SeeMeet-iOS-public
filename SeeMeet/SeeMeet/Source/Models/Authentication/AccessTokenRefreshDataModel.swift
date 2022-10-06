//
//  AccessTokenRefreshDataModel.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/08/20.
//

import Foundation

struct AccessTokenRefreshDataModel: Codable {
    let status: Int
    let success: Bool
    let message: String?
    let data: TokenRefreshData?
}

struct TokenRefreshData: Codable {
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "accesstoken"
        case refreshToken = "refreshtoken"
    }
}
