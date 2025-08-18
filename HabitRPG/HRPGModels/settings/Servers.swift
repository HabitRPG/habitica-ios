//
//  Servers.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.10.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation

enum Servers: String, Identifiable {
    var id: RawValue { rawValue }
    
    case production
    case staging
    
    case bat
    case frog
    case llama
    case monkey
    case seal
    case shrimp
    case starfish
    case turtle
    
    var niceName: String {
        switch self {
        case .production:
            return "⚙️ Production"
        case .staging:
            return "🎤 Staging"
        case .bat:
            return "🦇 Bat"
        case.frog:
            return "🐸 Frog"
        case.llama:
            return "🦙 Llama"
        case .monkey:
            return "🐒 Monkey"
        case .seal:
            return "🦭 Seal"
        case .shrimp:
            return "🦐 Shrimp"
        case .starfish:
            return "⭐️ Starfish"
        case .turtle:
            return "🐢 Turtle"
        }
    }
    
    static var allServers: [Servers] {
        return [
            .production,
            .staging,
            .bat,
            .frog,
            .llama,
            .monkey,
            .seal,
            .shrimp,
            .starfish,
            .turtle
        ]
    }
}
