//
//  APIContributor.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIContributor: ContributorProtocol, Codable {
    var level: Int = 0
    var admin: Bool = false
    var text: String?
    var contributions: String?
}
