//
//  Router.swift
//  StarWarsAlamofireAPI
//
//  Created by Craig Holliday on 8/17/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import Alamofire

protocol Route {
    var method: HTTPMethod { get }
    var url: URL { get }
    var params: [String: Any]? { get }
}

struct Router: URLRequestConvertible {
    static let baseURLString = "https://swapi.co/api/"
    
    let route: Route
    
    init(_ route: Route) {
        self.route = route
    }
    
    func asURLRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: route.url)
        urlRequest.httpMethod = route.method.rawValue
        
        // Set OAuth token if we have one
//        if let token = GitHubAPIManager.sharedInstance.OAuthToken {
//            urlRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
//        }
        
        let encoding: ParameterEncoding = {
            switch route.method {
            case .get:
                return URLEncoding.default
            default:
                return JSONEncoding.default
            }
        }()

        return try encoding.encode(urlRequest, with: route.params)
    }
}
