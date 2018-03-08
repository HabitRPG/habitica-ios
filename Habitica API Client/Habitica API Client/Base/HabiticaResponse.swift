//
//  HabiticaResponse.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public class HabiticaResponse<T: Codable>: Codable {
    var success: Bool = false
    var data: T?
    
    var error: String?
    var message: String?
    var userV: Int?
}
