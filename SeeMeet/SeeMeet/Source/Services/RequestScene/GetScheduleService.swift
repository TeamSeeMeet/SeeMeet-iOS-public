//
//  GetScheduleService.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/01/21.
//

import Alamofire
import Foundation

struct GetScheduleService {
    
    // MARK: - properties
    
    static let shared = GetScheduleService()
    
    private var headers: HTTPHeaders?
    
    // MARK: - initializer
    
    init() {
        guard let headers = TokenUtils.shared.getAuthorizationHeader() else { return }
        self.headers = headers
    }
    
    // MARK: - Methods
    
    func getScheduleData(year: String,
                         month: String,
                         completion: @escaping (NetworkResult<Any>) -> Void) {
        let url = Constants.URL.invitationPlanURL(year, month)
        
        let request = AF.request(url,
                                 method: .get,
                                 headers: headers)
        
        request.responseData { responseData in
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
        case 400: return .pathErr
        case 500: return .serverErr
        default: return .networkFail
        }
    }
    
    private func isValidDecodableData(data: Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(InvitationPlanData.self, from: data) else { return .pathErr }
        if decodedData.status == 200 {
            return .success(decodedData)
        } else {
            return .pathErr
        }
    }
}
