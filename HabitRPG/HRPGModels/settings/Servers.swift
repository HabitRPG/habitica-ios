//
//  Servers.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.10.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation

enum Servers: String {
    case production
    case staging
    case beta
    case gamma
    case delta
    
    var niceName: String {
        switch self {
        case .production:
            return "Production"
        case .staging:
            return "Staging"
        case .beta:
            return "Beta"
        case.gamma:
            return "Gamma"
        case.delta:
            return "Delta"
        }
    }
    
    static var allServers: [Servers] {
        return [
            .production,
            .staging,
            .beta,
            .gamma,
            .delta
        ]
    }
}
