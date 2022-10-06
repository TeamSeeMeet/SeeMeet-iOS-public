//
//  KakaoAuthService.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/03/06.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import Alamofire

struct KakaoAuthService {
    static let shared = KakaoAuthService()
    
    private let URL = Constants.URL.socialLoginURL
    private let provider: String = "kakao"
    
    static var isKakaoLogined: Bool = false
    
    func login(completion: @escaping (NetworkResult<Any>) -> Void) {
        logout()
        if (UserApi.isKakaoTalkLoginAvailable()) { // 1. 카카오톡 설치 여부를 확인한다.
            UserApi.shared.loginWithKakaoTalk {(OAuthToken, error) in
                if let error = error {
                    print(error)
                    return
                } else {
                    print("loginWithKakaoTalk() success.")
                    guard let OAuthToken = OAuthToken else { return }
                    
                    TokenUtils.shared.create(account: "kakaoOAuthToken", value: OAuthToken.accessToken)
                    requestLoginToService(kakaoToken: OAuthToken, completion: completion)
                }
            }
        } else { // 카카오톡 미설치시 사파리를 통해 카카오 계정으로 로그인한다.
            UserApi.shared.loginWithKakaoAccount { (OAuthToken, error) in
                if let error = error {
                    print(error)
                    return
                } else {
                    print("loginWithKakaoAccount() success.")
                    guard let OAuthToken = OAuthToken else { return }
                    // 2. 소셜 토큰 받아서 키체인에 저장
                    TokenUtils.shared.create(account: "kakaoOAuthToken", value: OAuthToken.accessToken)
                    requestLoginToService(kakaoToken: OAuthToken, completion: completion)
                }
            }
        }
        
        func requestLoginToService(kakaoToken: OAuthToken, completion: @escaping (NetworkResult<Any>) -> Void) { // 3. 유저의 카카오 프로필정보를 조회해서 닉네임(유저이름)을 가져온다.
            UserDefaults.standard.set("kakao", forKey: "loginBy") // 카카오로 로그인 했는지 여부
            
            UserApi.shared.me { user, error in
                if let error = error {
                    print(error)
                } else {
                    if let user = user {
                        guard let nickname = user.properties?["nickname"] else { return }
                        
                        let headers: HTTPHeaders = ["Content-Type": "application/json"]
                        
                        let parameters: Parameters = [
                            "socialtoken": kakaoToken.accessToken,
                            "name": nickname,
                            "provider": provider,
                            "fcm": UserDefaults.standard.string(forKey: "fcmToken") ?? ""
                        ]
                        
                        // 4. 씨밋 로그인 서버로 로그인 요청한다.
                        let request = AF.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                        request.responseData { response in
                            dump(response)
                            switch response.result {
                            case .success:
                                guard let statusCode = response.response?.statusCode,
                                      let value = response.value else { return }
                                
                                let networkResult = self.judgeStatus(by: statusCode, value)
                                completion(networkResult)
                            case .failure:
                                completion(.pathErr)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func logout() {
        UserApi.shared.logout {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("logout() success.")
            }
        }
    }
    
    func unlink() { // 카카오 계정과 연동 끊기, 로그아웃도 함께 이뤄진다.
        UserApi.shared.unlink {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("unlink() success.")
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
