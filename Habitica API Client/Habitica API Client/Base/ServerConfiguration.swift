//
//  ServerConfiguration.swift
//  Pods
//
//  Created by Elliot Schrock on 9/11/17.
//
//

import Foundation
import ReactiveSwift

public protocol ServerConfigurationProtocol {
    var shouldStub: Bool { get }
    var scheme: String { get }
    var host: String { get }
    var apiBaseRoute: String? { get }
    var urlConfiguration: URLSessionConfiguration { get set }
}

open class ServerConfiguration: ServerConfigurationProtocol {
    public let shouldStub: Bool
    public let scheme: String
    public let host: String
    public let apiBaseRoute: String?
    public var urlConfiguration: URLSessionConfiguration

    public init(shouldStub: Bool = false, scheme: String = "https", host: String, apiRoute: String?, urlConfiguration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.shouldStub = shouldStub
        self.scheme = scheme
        self.host = host
        self.apiBaseRoute = apiRoute
        self.urlConfiguration = urlConfiguration
    }
}
