//
//  PutNameAndIdService.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/04/23.
//

import Foundation
import Alamofire

struct PutNameAndIdService {
    static let shared = PutNameAndIdService()
    
    private let URL = Constants.URL.putNameAndIdURL
    
    enum RequestError: Error {
        case missingError // 값이 없을 경우
        case duplicateError // 중복 닉네임의 경우
    }
    
    func putNameAndId(name: String?, userId: String,
                      accessToken: String, completion: @escaping (NetworkResult<Any>) -> Void) {
        let header : HTTPHeaders = ["Content-Type": "application/json", "accesstoken": accessToken]
        
        var requestBody: Parameters = [
            "nickname": userId
        ]
        
        if let name {
            requestBody["name"] = name
        }
        
        let response = AF.request(URL, method: .put, parameters: requestBody, encoding: JSONEncoding.default, headers: header)
        
        response.responseData { responseData in
            switch responseData.result {
            case .success:
                if let statusCode = responseData.response?.statusCode,
                   let value = responseData.value {
                    let networkResult = judgeStatus(by: statusCode, value)
                    completion(networkResult)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(.networkFail)
            }
        }
    }
    
    private func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        switch statusCode {
        case 200: return isValidDecodableData(data: data)
        case 400: return isValidDecodableData(data: data)
        case 404: return .pathErr
        case 500: return .serverErr
        default: return .networkFail
        }
    }
    
    
    private func isValidDecodableData(data: Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(PutNameAndIdResponseDataModel.self, from: data) else { return .pathErr }
        if decodedData.status == 200 {
            return .success(decodedData)
        } else if decodedData.status == 400 {
            let message = decodedData.message
            if message == "이미 사용중인 닉네임입니다." {
                return .requestErr(RequestError.duplicateError)
            } else {
                return .requestErr(RequestError.missingError)
            }
        }
        else {
            return .pathErr
        }
    }
}
