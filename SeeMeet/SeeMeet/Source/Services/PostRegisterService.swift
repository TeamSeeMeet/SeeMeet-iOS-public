import Foundation
import Alamofire

struct PostRegisterService {
    
    static let shared = PostRegisterService()
    
    private func makeParameter(email: String,
                               password: String,
                               passwordConfirm: String) -> Parameters
    {
        return ["email": email, "password": password, "passwordConfirm": passwordConfirm]
    }

    func register(email: String,
                  password: String,
                  passwordConfirm: String,
                  completion : @escaping (NetworkResult<Any>) -> Void)
    {
        let header : HTTPHeaders = ["Content-Type": "application/json"]
        let dataRequest = AF.request(Constants.URL.registerURL,
                                     method: .post,
                                     parameters: makeParameter(email: email,
                                                               password: password,
                                                               passwordConfirm: passwordConfirm),
                                     encoding: JSONEncoding.default,
                                     headers: header)
        dataRequest.responseData { dataResponse in
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
        print(data)
        guard let decodedData = try? decoder.decode(RegisterDataModel.self, from: data)
        else {
            return .pathErr
        }
        switch statusCode {
        case 200, 404:
            //404가 이제 중복된 이메일 있을때
            return .success(decodedData)
        case 400:
            return .requestErr(decodedData.message)
        case 500:
            return .serverErr
        default: return .networkFail
        }
    }
}
