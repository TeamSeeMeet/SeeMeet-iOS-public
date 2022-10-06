//
//  PostRefreshAccessTokenService.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/08/20.
//

import Foundation
import Alamofire

class PostRefreshAccessTokenService {
    
    static let shared = PostRefreshAccessTokenService()
    
    func tokenRefresh(completion : @escaping (NetworkResult<Any>) -> Void) {
        let URL = Constants.URL.refreshAccessTokenURL
        
        var headers = TokenUtils.shared.getAuthorizationHeader()
        headers?.add(HTTPHeader(name: "refreshtoken", value: TokenUtils.shared.read(account: "refreshToken") ?? ""))
        
        let dataRequest = AF.request(URL, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        
        dataRequest.responseData { dataResponse in
            switch dataResponse.result {
            case .success:
                guard let statusCode = dataResponse.response?.statusCode else { return }
                guard let value = dataResponse.value else {return}
                let networkResult = self.judgeStatus(by: statusCode, value)
                completion(networkResult)
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        switch statusCode {
        case 200: return isValidData(data: data)
        case 400: return .pathErr
        case 401: return .requestErr(data) // 액세스 토큰이 만료 된 후 리프레시 토큰 또한 만료된 경우
        case 500: return .serverErr
        default: return .networkFail
        }
    }
    
    private func isValidData(data : Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        
        guard let decodedData = try? decoder.decode(AccessTokenRefreshDataModel.self, from: data) else {
            return .pathErr
        }
        
        return .success(decodedData)
    }
}
