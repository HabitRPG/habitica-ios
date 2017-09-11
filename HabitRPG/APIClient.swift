//
//  APIClient.swift
//  Habitica
//
//  Created by Phillip on 10.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIClient {
    
    static let baseUrl = "https://habitica.com/api/v3/"
    
    static func retrieveTasks(completion: @escaping ([Task]) -> Void) {
        makeRequest("tasks/user", method: .get) { (jsonData) in
            completion(jsonData.arrayValue.map {Task(json: $0)})
        }
    }
    
    static func makeRequest(_ url: String, method: HTTPMethod, completion: @escaping (_ json: JSON) -> Void) {
        makeRequest(url, method: method, data: nil, completion: completion)
    }
    
    static func makeRequest(_ url: String, method: HTTPMethod, data: [String:AnyObject]?, completion: @escaping (_ json: JSON) -> Void) {
        let headers: HTTPHeaders = [
            "x-api-user": AuthenticationManager.shared.currentUserId ?? "",
            "x-api-key": AuthenticationManager.shared.currentUserKey ?? "",
            "Accept": "application/json"
        ]
        Alamofire.request(baseUrl + url, method: method, parameters: data, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    completion(JSON(value))
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
