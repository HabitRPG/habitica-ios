//
//  HRPGAPI.swift
//  Habitica
//
//  Created by Craig Holliday on 8/18/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

enum KeychainKeys {
    static let userid = "id"
    static let apiToken = "apiToken"
}

enum JSONKeys {
    static let data = "data"
    static let userId = "id"
    static let apiToken = "apiToken"
    static let message = "message"
}

public enum APIErrors: Error {
    case jsonConversionError
    case errorWithNoErrorResponse
}

extension APIErrors: LocalizedError {
    public var errorDescription: String? {
        return "Unknown Error".localized
    }
}

enum Networks: String {
    case facebook
    case google
}

public class HRPGAPI {
    static let shared: HRPGAPI = HRPGAPI()
    private init() {}
    
    typealias SuccessCallback = () -> Void
    typealias ErrorCallback = (Error) -> Void
    
    func userLogin(username: String,
                   password: String,
                   onSuccess: SuccessCallback? = nil,
                   onError: ErrorCallback? = nil) {
        let route = UserLoginRoute(username: username, password: password)
        let router = Router(route)
        Alamofire.request(router)
            .responseJSON { response in
                switch response.result {
                case .success:
                // Make sure we get some JSON data
                guard let jsonData = response.result.value as? [String: Any] else {
                    guard let errorResponse = response.result.error else {
                        onError?(APIErrors.errorWithNoErrorResponse)
                        return }
                    onError?(errorResponse)
                    return
                }
                
                let json = JSON(jsonData)
                
                // Check for error messages
                if let message = json[JSONKeys.message].string {
                    let error = NSError(domain: message, code: response.response?.statusCode ?? 0, userInfo: nil)
                    onError?(error)
                    return
                }
                
                guard let id = json[JSONKeys.data][JSONKeys.userId].string
                    else {
                        onError?(APIErrors.jsonConversionError)
                        return }
                guard let apiToken = json[JSONKeys.data][JSONKeys.apiToken].string
                    else {
                        onError?(APIErrors.jsonConversionError)
                        return }
                
                // Key == apiToken
                AuthenticationManager.shared.setAuthentication(userId: id, key: apiToken)

                // Notification Post
                NotificationCenter.default.post(name: .userChanged, object: nil)
                
                // Completion Success
                onSuccess?()

                case .failure(let error):
                    // Check for errors
                    onError?(error)
                }
        }
    }
    
    func userLoginSocial(userID: String,
                         network: Networks,
                         accessToken: String,
                         onSuccess: SuccessCallback? = nil,
                         onError: ErrorCallback? = nil) {
        let route = UserSocialLoginRoute(userID: userID, network: network.rawValue, accessToken: accessToken)
        let router = Router(route)
        Alamofire.request(router)
            .responseJSON { response in
                switch response.result {
                case .success:
                    // Make sure we get some JSON data
                    guard let jsonData = response.result.value as? [String: Any] else {
                        guard let errorResponse = response.result.error else {
                            onError?(APIErrors.errorWithNoErrorResponse)
                            return }
                        onError?(errorResponse)
                        return
                    }
                    
                    // Set keychain keys
                    let json = JSON(jsonData)
                    
                    // Check for error messages
                    if let message = json[JSONKeys.message].string {
                        let error = NSError(domain: message, code: response.response?.statusCode ?? 0, userInfo: nil)
                        onError?(error)
                        return
                    }
                    
                    guard let id = json[JSONKeys.data][JSONKeys.userId].string
                        else {
                            onError?(APIErrors.jsonConversionError)
                            return }
                    guard let apiToken = json[JSONKeys.data][JSONKeys.apiToken].string
                        else {
                            onError?(APIErrors.jsonConversionError)
                            return }
                    
                    // Key == apiToken
                    AuthenticationManager.shared.setAuthentication(userId: id, key: apiToken)
                    
                    // Notification Post
                    NotificationCenter.default.post(name: .userChanged, object: nil)
                    
                    // Completion Success
                    onSuccess?()
                case .failure(let error):
                    // check for errors
                    onError?(error)
                }
        }
    }
    
    func userRegister(username: String,
                      password: String,
                      confirmPassword: String,
                      email: String,
                      onSuccess: SuccessCallback? = nil,
                      onError: ErrorCallback? = nil) {
        let route = UserRegisterRoute(username: username, password: password, confirmPassword: password, email: email)
        let router = Router(route)
        Alamofire.request(router)
            .responseJSON { response in
                switch response.result {
                case .success:
                    // Make sure we get some JSON data
                    guard let jsonData = response.result.value as? [String: Any] else {
                        guard let errorResponse = response.result.error else {
                            onError?(APIErrors.errorWithNoErrorResponse)
                            return }
                        onError?(errorResponse)
                        return
                    }
                    
                    // Set keychain keys
                    let json = JSON(jsonData)
                    
                    // Check for error messages
                    if let message = json[JSONKeys.message].string {
                        let error = NSError(domain: message, code: response.response?.statusCode ?? 0, userInfo: nil)
                        onError?(error)
                        return
                    }
                    
                    // Register success so Login
                    self.userLogin(username: username, password: password, onSuccess: {
                        onSuccess?()
                    }, onError: { (error) in
                        onError?(error)
                    })
                case .failure(let error):
                    // check for errors
                    onError?(error)
                }
        }
    }
}
