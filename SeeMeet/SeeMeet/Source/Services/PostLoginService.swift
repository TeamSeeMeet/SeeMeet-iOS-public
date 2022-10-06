import Foundation
import Alamofire

struct PostLoginService {
    
    static let shared = PostLoginService()
    
    private func makeParameter(email: String,
                               password: String) -> Parameters {
        return ["email": email, "password": password]
    }
    
    func login(email: String,
               password: String,
               completion : @escaping (NetworkResult<Any>) -> Void) {
        let header : HTTPHeaders = ["Content-Type": "application/json"]
        let dataRequest = AF.request(Constants.URL.loginURL,
                                     method: .post,
                                     parameters: makeParameter(email: email,
                                                               password: password),
                                     encoding: JSONEncoding.default,
                                     headers: header)
        dataRequest.responseData { dataResponse in
            dump(dataResponse)
            switch dataResponse.result {
            case .success:
                guard let statusCode = dataResponse.response?.statusCode else { return }
                guard let value = dataResponse.value else { return }
                
                let networkResult = self.judgeStatus(by: statusCode, value)
                completion(networkResult)
                
            case .failure: completion(.pathErr)
                
            }
        }
    }
    
    private func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(EmailLoginResponseModel.self, from: data) else {
            return .pathErr
        }
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
