//
//  Routes.swift
//  StarWarsAlamofireAPI
//
//  Created by Craig Holliday on 8/17/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import Alamofire

struct getPeopleRoute: Route {
    var method: HTTPMethod = .get
    
    var url: URL {
        get {
            let relativePath = "people"
            var url = URL(string: Router.baseURLString)!
            url.appendPathComponent(relativePath)
            return url
        }
    }
    
    var params: [String: Any]? = nil
    
    // Init with params
    init(search: String? = nil) {
        params = ["search": search ?? ""]
    }
}
