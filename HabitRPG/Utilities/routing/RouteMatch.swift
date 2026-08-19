//
//  RouteMatch.swift
//  Habitica
//
//  Created by Phillip Thelen on 19.08.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//


import Foundation
import Habitica_Models
import Habitica_API_Client

struct RouteMatch {
    let matches: Bool
    let parameters: [String: String]
}
