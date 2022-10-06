//
//  PostProfileImageService.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/06/29.
//

import Foundation
import Alamofire

struct PostProfileImageService {
    
    static let shared = PostProfileImageService()
    
    func postProfileImage(imageData: UIImage?,accessToken: String, completion: @escaping (NetworkResult<Any>) -> Void) {
        
        let URL = Constants.URL.postProfileImageURL
        let header : HTTPHeaders = [
            "Content-Type" : "multipart/form-data",
            "accesstoken" : accessToken ]
             
        AF.upload(multipartFormData: { multipartFormData in
            if let image = imageData?.pngData() {
                multipartFormData.append(image, withName: "file", fileName: "profileImage.png", mimeType: "image/png")
            }
        }, to: URL, usingThreshold: UInt64.init(), method: .post, headers: header).response { dataResponse in
            guard let statusCode = dataResponse.response?.statusCode,
                  statusCode == 200
            else { return }
            completion(.success(statusCode))
        }
        
    }

}
