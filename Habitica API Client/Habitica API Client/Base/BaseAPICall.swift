//
//  BaseAPICall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Alamofire
import Habitica_Models

public class BaseAPICall<P: Codable> {
    let baseURL = "https://habitica.com/api/v3/"
    
    var relativeURL: String = ""
    var method: HTTPMethod = .get
    var data: [String:AnyObject]?
    
    var url: String {
        return baseURL + relativeURL
    }
    
    func decode(with decoder: JSONDecoder, data: Data) throws -> P? {
        return try decoder.decode(P.self, from: data)
    }
    
    public func execute(completion: @escaping (_ result: P?) -> Void) {
        let headers: HTTPHeaders = [
            "x-api-user": NetworkAuthenticationManager.shared.currentUserId ?? "",
            "x-api-key": NetworkAuthenticationManager.shared.currentUserKey ?? "",
            "Accept": "application/json"
        ]
        Alamofire.request(url, method: method, parameters: data, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else {
                    return
                }
                
                guard let jsonValue = response.result.value as? Dictionary<String, Any> else {
                    return
                }
                
                guard let data = try? JSONSerialization.data(withJSONObject: jsonValue["data"]) else {
                    return
                }
                
                if 200...299 ~= statusCode {
                    let decoder = JSONDecoder()
                    if #available(iOS 10.0, *) {
                        decoder.dateDecodingStrategy = .custom({ dateDecoder -> Date in
                            let container = try dateDecoder.singleValueContainer()
                            let dateStr = try container.decode(String.self)

                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
                            
                            return dateFormatter.date(from: dateStr) ?? Date()
                        })
                    }
                    do {
                        completion(try self.decode(with: decoder, data: data))
                    } catch {
                        print(error)
                    }
                }
            case .failure:
                var errorMessage = "General error message"
                
                if let data = response.data {
                }
                
                print(errorMessage)
            }
        }
    }
}
