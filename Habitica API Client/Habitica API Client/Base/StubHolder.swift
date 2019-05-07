//
//  StubHolder.swift
//  Pods
//
//  Created by Elliot Schrock on 9/15/17.
//
//

import Foundation

public protocol StubHolderProtocol {
    var responseCode: Int32 { get }
    var stubFileName: String? { get }
    var bundle: Bundle { get }
    var stubData: Data? { get }
    var responseHeaders: [String: String] { get }
}

open class StubHolder: StubHolderProtocol {
    public let responseCode: Int32
    public let stubFileName: String?
    public let bundle: Bundle
    public let stubData: Data?
    public let responseHeaders: [String : String]
    
    public init(responseCode: Int32 = 200, stubFileName: String? = nil, stubData: Data? = nil, responseHeaders: [String: String] = ["Content-type":"application/json"], bundle: Bundle = Bundle.main) {
        self.responseCode = responseCode
        self.stubFileName = stubFileName
        self.bundle = bundle
        self.stubData = stubData
        self.responseHeaders = responseHeaders
    }
}
