import Foundation
import Alamofire

struct PostInvitationService {
    
    static let shared = PostInvitationService()
    
    private func makeParameter(invitationDateIds: [Int]) -> Parameters {
        return ["invitationDateIds": invitationDateIds]
    }
    
    func postInvitation(plansId: String, invitationDateIds: [Int],
                        completion : @escaping (NetworkResult<Any>) -> Void) {
        let header : HTTPHeaders = TokenUtils.shared.getAuthorizationHeader() ?? ["Content-Type": "application/json"]
        let URL = Constants.URL.plansRequestURL(plansId)
        let dataRequest = AF.request(URL,
                                     method: .post,
                                     parameters: makeParameter(invitationDateIds: invitationDateIds),
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
        guard let decodedData = try? decoder.decode(InvitationPlansDataModel.self, from: data) else {
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
