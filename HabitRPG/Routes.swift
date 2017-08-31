//
//  Routes.swift
//  Habitica
//
//  Created by Craig Holliday on 8/18/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Foundation
import Alamofire

enum Endpoints {
    static let userAuth = "user/auth"
    static let login = Endpoints.userAuth + "/local/login"
    static let loginSocial = Endpoints.userAuth + "/social"
    static let register = Endpoints.userAuth + "/local/register"
}

enum Params {
    static let username = "username"
    static let password = "password"
    static let confirmpassword = "confirmPassword"
    static let email = "email"
    
    static let network = "network"
    static let clientId = "client_id" // userID
    static let accessToken = "access_token"
    static let authResponse = "authResponse"
}

protocol Route {
    var method: HTTPMethod { get }
    var url: URL? { get }
    var params: [String: Any]? { get }
}

struct UserLoginRoute: Route {
    var method: HTTPMethod = .post
    
    var url: URL? {
        get {
            let relativePath = Endpoints.login
            guard var url = URL(string: Router.baseURLString)
                else { return nil }
            url.appendPathComponent(relativePath)
            return url
        }
    }
    
    var params: [String: Any]?
    
    // Init with params
    init(username: String, password: String) {
        params = [Params.username: username, Params.password: password]
    }
}

struct UserSocialLoginRoute: Route {
    var method: HTTPMethod = .post
    
    var url: URL? {
        get {
            let relativePath = Endpoints.loginSocial
            guard var url = URL(string: Router.baseURLString)
                else { return nil }
            url.appendPathComponent(relativePath)
            return url
        }
    }
    
    var params: [String: Any]?
    
    // Init with params
    init(userID: String, network: String, accessToken: String) {
        params = [Params.network: network,
                  Params.authResponse: [Params.clientId: userID, Params.accessToken: accessToken]
        ]
    }
}

struct UserRegisterRoute: Route {
    var method: HTTPMethod = .post
    
    var url: URL? {
        get {
            let relativePath = Endpoints.register
            guard var url = URL(string: Router.baseURLString)
                else { return nil }
            url.appendPathComponent(relativePath)
            return url
        }
    }
    
    var params: [String: Any]?
    
    // Init with params
    init(username: String, password: String, confirmPassword: String, email: String) {
        params = [Params.username: username, Params.password: password, Params.confirmpassword: confirmPassword, Params.email: email]
    }
}
