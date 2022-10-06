import Foundation
import Alamofire

struct CalendarService {
    
    // MARK: - properties
    
    static let shared = CalendarService()
    
    private var headers: HTTPHeaders?
    
    // MARK: - initializer
    
    init() {
        guard let headers = TokenUtils().getAuthorizationHeader() else { return }
        self.headers = headers
    }
    
    // MARK: - Methods
    
    func getPlanDatas(year: String,
                      month: String,
                      completion: @escaping (NetworkResult<Any>) -> Void) {
        let url = Constants.URL.calendarURL(year, month)
        
        let request = AF.request(url,
                   method: .get,
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
    
    func getDetailPlanData(planID: Int,
                           completion: @escaping (NetworkResult<Any>) -> Void) {
        let url = Constants.URL.baseURL + "/plan/detail/\(planID)"
        
        let request = AF.request(url,
                                 method: .get,
                                 headers: headers).validate()
        
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
        if let decodedData = try? decoder.decode(MonthlyPlansResponseModel.self, from: data){
            return .success(decodedData)
        } else {
            if let decodedData = try? decoder.decode(PlanDetailResponseModel.self, from: data) {
                return .success(decodedData)
            } else {
                return .pathErr
            }
        }
    }
}
