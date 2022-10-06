//
//  PostPushSetService.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/08/11.
//

import Foundation
import Alamofire

struct PostPushNotificationSetService {
    static let shared = PostPushNotificationSetService()
    
    func pushSet(isNotificationOn: Bool, completion : @escaping (NetworkResult<Any>) -> Void) {
        let URL = Constants.URL.postNotificationSetURL
        guard let fcmToken = UserDefaults.standard.string(forKey: "fcmToken"),
              let headers = TokenUtils.shared.getAuthorizationHeader() else { return }
        
        let parameters: Parameters = [
            "push": isNotificationOn,
            "fcm": fcmToken
        ]
        
        let dataRequest = AF.request(URL,
                                     method: .post,
                                     parameters: parameters,
                                     encoding: JSONEncoding.default,
                                     headers: headers)
        
        dataRequest.responseData { responseData in
            dump(responseData)
            switch responseData.result {
            case .success(let data):
                guard let statusCode = responseData.response?.statusCode else { return }
                guard let value = responseData.value else { return }
                
                let networkResult = self.judgeStatus(by: statusCode, value)
                completion(networkResult)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    private func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(NotificationSetResponseModel.self, from: data) else {
            return .pathErr
        }
        switch statusCode {
        case 200...399:
            return .success(decodedData)
        case 400...404:
            print(decodedData.message)
            return .requestErr(decodedData.message)
        case 500:
            return .serverErr
        default: return .networkFail
        }
    }
}
