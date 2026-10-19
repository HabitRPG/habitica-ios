//
//  ClientConfigOption.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 15.10.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//

public class AnyClientConfigKey: @unchecked Sendable {
    public let key: String
    init(key: String) { self.key = key }
}

public final class ClientConfigKey<Value: Codable & Sendable>: AnyClientConfigKey, @unchecked Sendable {
    public let defaultValue: Value
    public init(_ key: String, default defaultValue: Value) {
        self.defaultValue = defaultValue
        super.init(key: key)
    }
}
