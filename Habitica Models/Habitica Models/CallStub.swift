//
//  CallStub.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 14.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation

public class CallStub: Codable {
    public var responses: [String]
    public var validations: [String]?
    
    public init(response: String, validation: String? = nil) {
        responses = [response]
        if let validation = validation {
            validations = [validation]
        }
    }
    
    public init(responses: [String], validations: [String]? = nil) {
        self.responses = responses
        self.validations = validations
    }
    
    public func takeNextResponse() -> String {
        if responses.count > 1 {
            return responses.removeFirst()
        }
        return responses.first ?? ""
    }
    
    public func takeNextValidation() -> String? {
        if (validations?.count ?? 0) > 1 {
            return validations?.removeFirst()
        }
        return validations?.first
    }
}
