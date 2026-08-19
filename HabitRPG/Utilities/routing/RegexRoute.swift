//
//  RegexRoute.swift
//  
//
//  Created by Phillip Thelen on 19.08.26.
//


import Foundation
import Habitica_Models
import Habitica_API_Client

struct RegexRoute {
    static private let parameterURLRegex = ":[a-zA-Z0-9-_]+"
    static private let defaultURLRegex = "([^/]+)"
    
    let call: (([String: String]) async -> Void)
    let regex: NSRegularExpression
    let groupNames: [String]
    
    init(route: String, call: @escaping (([String: String]) async -> Void)) {
        self.call = call
        let expression = try? NSRegularExpression(pattern: RegexRoute.parameterURLRegex)
        let range = NSRange(location: 0, length: route.count)
        // swiftlint:disable:next force_try
        self.regex = try! NSRegularExpression(pattern: expression?.stringByReplacingMatches(in: route, range: range, withTemplate: RegexRoute.defaultURLRegex) ?? route)
        groupNames = expression?.matches(in: route, range: range).map({ result in
            return String((route as NSString).substring(with: result.range).dropFirst())
        }) ?? []
    }
    
    func matches(_ path: String) -> RouteMatch? {
        let matches = regex.matches(in: path, range: NSRange(location: 0, length: path.count))
        guard let match = matches.first else {
            return nil
        }
        if matches.count == 1 && (match.numberOfRanges - 1) == groupNames.count {
            var parameters = [String: String]()
            for rangeIndex in 1..<match.numberOfRanges {
                parameters[groupNames[rangeIndex-1]] = (path as NSString).substring(with: match.range(at: rangeIndex))
            }
            return RouteMatch(matches: true, parameters: parameters)
        }
        return nil
    }
}
