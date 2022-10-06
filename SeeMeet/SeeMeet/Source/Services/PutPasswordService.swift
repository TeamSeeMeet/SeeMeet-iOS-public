import Alamofire
import Foundation

struct PutPasswordService {
    static let shared = PutPasswordService()
    
    func putPassword(password: String, completion : @escaping (NetworkResult<Any>) -> Void) {
        // completion 클로저를 @escaping closure로 정의합니다.
        let URL = Constants.URL.putPasswordUrl
        let header : HTTPHeaders = TokenUtils.shared.getAuthorizationHeader() ?? ["Content-Type": "application/json"]
        let requestBody: Parameters = ["password": password, "passwordConfirm": password]

        let dataRequest = AF.request(URL,
                                     method: .put,
                                     parameters: requestBody,
                                     encoding: JSONEncoding.default,
                                     headers: header)

        dataRequest.responseData { dataResponse in
            switch dataResponse.result {
            case .success:
                guard let statusCode = dataResponse.response?.statusCode else {return}
                guard let value = dataResponse.value else {return}
                let networkResult = self.judgeStatus(by: statusCode, value)
                completion(networkResult)

            case .failure: completion(.pathErr)
                print("실패 사유")
            }
        }
    }
    
    private func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        switch statusCode {
        case 200: return isValidData(data: data)
        case 400: return .pathErr
        case 500: return .serverErr
        default: return .networkFail
        }
    }
    
    private func isValidData(data : Data) -> NetworkResult<Any> {
        
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(PasswordResponseModel.self, from: data)
                
        else {print("안됨"); return .pathErr }
        print(decodedData)
        return .success(decodedData)
    }
}
