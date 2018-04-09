//
//  LoginResponseProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol LoginResponseProtocol {
    var id: String { get set }
    var apiToken: String { get set }
}
