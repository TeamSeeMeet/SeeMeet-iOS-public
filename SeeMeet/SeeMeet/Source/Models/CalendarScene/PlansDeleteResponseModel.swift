//
//  PlansDeleteReponseModel.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/08/09.
//

import Foundation

// MARK: - PlansDeleteResponseModel
struct PlansDeleteResponseModel: Codable {
    let status: Int
    let success: Bool?
    let message: String?
}
