//
//  APIRoutes.swift
//  Habitica
//
//  Created by Craig Holliday on 8/17/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Foundation
import Alamofire

struct GetPeopleRoute: Route {
    var method: HTTPMethod = .get
    
    var url: URL? {
        get {
            let relativePath = "people"
            guard var url = URL(string: Router.baseURLString) else { return nil }
            url.appendPathComponent(relativePath)
            return url
        }
    }
    
    var params: [String: Any]?
    
    // Init with params
    init(search: String? = nil) {
        params = ["search": search ?? ""]
    }
}
