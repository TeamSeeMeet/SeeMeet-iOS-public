import Foundation
import Alamofire

struct PostPlansRequestAcceptService {
    
    static let shared = PostPlansRequestAcceptService()
    
    private func makeParameter(dateId: Int) -> Parameters {
        return ["dateId": dateId]
    }
    
    func postPlansRequestAccept(plansId: String, dateId: Int,
                                completion : @escaping (NetworkResult<Any>) -> Void) {
        
        let header : HTTPHeaders = TokenUtils.shared.getAuthorizationHeader() ?? ["Content-Type": "application/json"]
        let dataRequest = AF.request(Constants.URL.plansDetailURL(plansId),
                                     method: .post,
                                     parameters: makeParameter(dateId: dateId),
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
        guard let decodedData = try? decoder.decode(PlansRequestAcceptDataModel.self, from: data) else {
            return .pathErr
        }
        switch statusCode {
        case 200:
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
