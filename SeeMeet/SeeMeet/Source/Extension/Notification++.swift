//
//  Notification++.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/08/24.
//

import Foundation

extension NSNotification.Name {
    static let RefreshTokenExpired = NSNotification.Name("RefreshTokenExpired")
    static let PushNotificationDidSet = NSNotification.Name("PushNotificationDidSet")
    static let DidLogout = NSNotification.Name("DidLogout")
}
