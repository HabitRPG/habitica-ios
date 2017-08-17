//
//  APIRouter.swift
//  Habitica
//
//  Created by Craig Holliday on 8/17/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Foundation
import Alamofire

protocol Route {
    var method: HTTPMethod { get }
    var url: URL? { get }
    var params: [String: Any]? { get }
}

enum RouterError: Error {
    case urlRouteNil
}

struct Router: URLRequestConvertible {
    static let baseURLString = "https://habitica.com/" + "api/v3/"
    
    let route: Route
    
    init(_ route: Route) {
        self.route = route
    }
    
    func asURLRequest() throws -> URLRequest {
        guard let routeURL = route.url else { throw RouterError.urlRouteNil }
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
