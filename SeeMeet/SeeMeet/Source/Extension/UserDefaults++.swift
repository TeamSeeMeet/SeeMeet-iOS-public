//
//  UserDefaults++.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/03/27.
//

import UIKit

extension UserDefaults {
    public static func isFirstLaunch() -> Bool {
        let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: Constants.UserDefaultsKey.hasBeenLaunchedBeforeFlag)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKey.hasBeenLaunchedBeforeFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
    
    static func deleteUserValue() {
        TokenUtils.shared.delete(account: "accessToken")
        TokenUtils.shared.delete(account: "refreshToken")
        //유저디폴츠 값 수정 및 삭제
        let ud = UserDefaults.standard
        
        UserDefaults.standard.do {
            $0.set(false, forKey: Constants.UserDefaultsKey.isLogin)
            $0.set(false,forKey: Constants.UserDefaultsKey.isAppleLogin)
            $0.removeObject(forKey: Constants.UserDefaultsKey.userName)
            $0.removeObject(forKey: Constants.UserDefaultsKey.userNickname)
            $0.removeObject(forKey: Constants.UserDefaultsKey.userEmail)
        }
        guard let image = UIImage(named: "img_profile") else { return }
        ImageManager.shared.saveImage(image: image, named: "profile.png")
    }
}
