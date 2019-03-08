//
//  VerifyUsernameResponse.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 09.10.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol VerifyUsernameResponse {
    var isUsable: Bool { get set }
    var issues: [String]? { get set }
}
