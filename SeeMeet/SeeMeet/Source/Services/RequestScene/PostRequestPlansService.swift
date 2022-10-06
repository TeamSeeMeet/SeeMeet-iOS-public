import Foundation
import Alamofire
import RxSwift

class RequestPlansParameter {
    var guests: [[String: Any]] = []
    var title: String?
    var contents: String?
    var date: [String] = []
    var start: [String] = []
    var end: [String] = []
    
    func isAnyPropertyNotNil() -> Bool {
        !guests.isEmpty
        && title != nil
        && contents != nil
        && !date.isEmpty
        && !start.isEmpty
        && !end.isEmpty
    }
    
    func removeTimeData(at index: Int) {
        guard !date.isEmpty && !start.isEmpty && !end.isEmpty else { return } // 배열이 비었는지 검증한다.
        
        date.remove(at: index)
        start.remove(at: index)
        end.remove(at: index)
    }
    
    func removeAllData() {
        guests.removeAll()
        title?.removeAll()
        contents?.removeAll()
        date.removeAll()
        start.removeAll()
        end.removeAll()
    }
}

struct PostRequestPlansService {
    
    // MARK: - properties
    
    static let shared = PostRequestPlansService()
    
    private var headers: HTTPHeaders?
    
    /// 싱글턴 객체로 참조할 수 있게 한다. 약속 신청에 관한 데이터는 여기로 모은다.
    static let sharedParameterData = RequestPlansParameter()
    
    
    
    // MARK: - initializer
    
    init() {
        guard let headers = TokenUtils().getAuthorizationHeader() else { return }
        self.headers = headers
    }
    
    // MARK: - methods
    
    func requestPlans(completion: @escaping (NetworkResult<Any>) -> Void) {
        
        guard PostRequestPlansService.sharedParameterData.isAnyPropertyNotNil() else { return } // 값이 모두 채워져 있는지 검증한다.
        
        let url = Constants.URL.invitationURL
        
        let requestBody: Parameters = ["guests": PostRequestPlansService.sharedParameterData.guests,
                                       "invitationTitle": PostRequestPlansService.sharedParameterData.title ?? "",
                                       "invitationDesc": PostRequestPlansService.sharedParameterData.contents ?? "",
                                       "date": PostRequestPlansService.sharedParameterData.date,
                                       "start": PostRequestPlansService.sharedParameterData.start,
                                       "end": PostRequestPlansService.sharedParameterData.end]
   
        let request = AF.request(url,
                                 method: .post,
                                 parameters: requestBody,
                                 encoding: JSONEncoding.default,
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
    
    func requestPlans(guests: [[String: Any]], title: String, contents: String, date: [String],start: [String], end:[String],
                      completion: @escaping (NetworkResult<Any>) -> Void) {
        let url = Constants.URL.invitationURL
        
        let requestBody: Parameters = ["guests": guests,
                                       "invitationTitle": title,
                                       "invitationDesc": contents,
                                       "date": date,
                                       "start": start,
                                       "end": end]
   
        let request = AF.request(url,
                                 method: .post,
                                 parameters: requestBody,
                                 encoding: JSONEncoding.default,
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
        case 200, 400, 404: return isValidDecodableData(data: data)
        case 500: return .serverErr
        default: return.networkFail
        }
    }
    
    private func isValidDecodableData(data: Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(PlanRequestData.self, from: data) else { return .pathErr }
        if decodedData.status == 200 {
            return .success(decodedData)
        } else {
            return .requestErr(decodedData)
        }
    }
}

