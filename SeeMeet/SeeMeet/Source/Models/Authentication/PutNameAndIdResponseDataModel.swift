//
//  PutNameAndIdDataModel.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/04/23.
//

import Foundation

// MARK: - PutNameAndIdResponseDataModel
struct PutNameAndIdResponseDataModel: Codable {
    let status: Int
    let success: Bool
    let message: String
}

