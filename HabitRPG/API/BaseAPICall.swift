//
//  BaseAPICall.swift
//  Habitica
//
//  Created by Phillip on 17.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class BaseAPICall<T: JSONSerializable> {
    let baseURL = "https://habitica.com/api/v3/"
    
    var relativeURL: String = ""
    var method: HTTPMethod = .get
    var data: [String:AnyObject]?
    
    var url: String {
        return baseURL + relativeURL
    }
    
    func execute(completion: @escaping (_ result: T?) -> Void) {
        let headers: HTTPHeaders = [
            "x-api-user": AuthenticationManager.shared.currentUserId ?? "",
            "x-api-key": AuthenticationManager.shared.currentUserKey ?? "",
            "Accept": "application/json"
        ]
        Alamofire.request(url, method: method, parameters: data, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let rootJSON = JSON(value)
                    let object = try? T.init(json: rootJSON["data"])
                    completion(object)
                }
            case .failure:
                var errorMessage = "General error message"
                
                if let data = response.data {
                    let responseJSON = JSON(data: data)
                    
                    if let message: String = responseJSON.string {
                        if !message.isEmpty {
                            errorMessage = message
                        }
                    }
                }
                
                print(errorMessage)
            }
        }
    }
}
