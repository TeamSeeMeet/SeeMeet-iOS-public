//
//  AccessInterceptor.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/08/20.
//

import Foundation
import Alamofire

class AccessInterceptor: RequestInterceptor {
    
    static let shared = AccessInterceptor()
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print(request.response)
        print(request.response)
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        PostRefreshAccessTokenService.shared.tokenRefresh { response in
            switch response {
            case .success(let data):
                guard let tokenData = data as? TokenRefreshData else { return }
                TokenUtils.shared.create(account: "accessToken", value: tokenData.accessToken)
                TokenUtils.shared.create(account: "refreshToken", value: tokenData.refreshToken)
                completion(.retry)
            case .pathErr:
                print("pathErr")
                completion(.doNotRetry)
            case .networkFail:
                print("networkFail")
                completion(.doNotRetry)
            case .serverErr:
                print("serverErr")
                completion(.doNotRetry)
            case .requestErr(_): // 재 로그인 필요
                UserDefaults.deleteUserValue()
                NotificationCenter.default.post(name: Notification.Name.RefreshTokenExpired, object: nil)
                completion(.doNotRetry)
            }
        }
    }
}
