import Foundation
import Alamofire

struct FriendsSearchService {
    
    // MARK: - properties
    
    static let shared = FriendsSearchService()
    
    private var headers: HTTPHeaders?
    
    // MARK: - initializer
    
    init() {
        guard let headers = TokenUtils.shared.getAuthorizationHeader() else { return }
        self.headers = headers
    }
    
    // MARK: - methods
    
    func searchFriends(nickname: String,
                       completion: @escaping (NetworkResult<Any>) -> Void) {
        let url = Constants.URL.searchFriendsURL
        
        let requestBody: Parameters = ["nickname": nickname]
        
        let request = AF.request(url,
                                 method: .post,
                                 parameters: requestBody,
                                 encoding: JSONEncoding.default,
                                 headers: headers,
                                 interceptor: AccessInterceptor.shared)
        
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
        case 200, 400, 404: return isValidDecodableData(data: data)
        case 500: return .serverErr
        default: return.networkFail
        }
    }
    
    private func isValidDecodableData(data: Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(FriendsSearchResponseModel.self, from: data) else { return .pathErr }
        if decodedData.status == 200 {
            return .success(decodedData)
        } else {
            return .requestErr(decodedData)
        }
    }
}
