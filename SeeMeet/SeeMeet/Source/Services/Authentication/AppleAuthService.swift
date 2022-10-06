//
//  AppleAuthService.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/03/20.
//

import Foundation
import AuthenticationServices
import Alamofire

class AppleAuthService: NSObject {
    
    // MARK: - Properties
    
    static let shared = AppleAuthService()
    
    private let URL = Constants.URL.socialLoginURL
    private let provider: String = "apple" 

    func login(name: String,token: String,completion: @escaping (NetworkResult<Any>)->Void) {
        // 키체인에 apple token 저장
        TokenUtils.shared.create(account: "AppleUserIdentifier", value: token)
        
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        let parameters: Parameters = [
            "socialtoken": token,
            "name": name,
            "provider": provider,
            "fcm": UserDefaults.standard.string(forKey: "fcmToken") ?? ""
        ]
        
        let requestToAPI = AF.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        requestToAPI.responseData { response in
            dump(response)
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode,
                      let value = response.value else { return }
                
                let networkResult = self.judgeStatus(by: statusCode, value)
                UserDefaults.standard.set("apple", forKey: "loginBy")
                completion(networkResult)
            case .failure:
                completion(.pathErr)
            }
        }
    }
    
    private func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
           let decoder = JSONDecoder()
           guard let decodedData = try? decoder.decode(SocialLoginDataModel.self, from: data) else { return .pathErr }
           switch statusCode {
           case 200, 404:
               return .success(decodedData)
           case 400:
               print(decodedData.message)
               return .requestErr(decodedData.message)
           case 500:
               return .serverErr
           default: return .networkFail
           }
       }
}
