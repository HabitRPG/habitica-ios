//
//  Router.swift
//  Habitica
//
//  Created by Craig Holliday on 8/18/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Foundation
import Alamofire

enum RouterError: Error {
    case routeURLNil
}

struct Router: URLRequestConvertible {
    static let baseURLString = "https://habitica.com" + "/api/v3/"
    
    let route: Route
    
    init(_ route: Route) {
        self.route = route
    }
    
    func asURLRequest() throws -> URLRequest {
        guard let routeURL = route.url else { throw RouterError.routeURLNil }
        var urlRequest = URLRequest(url: routeURL)
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
