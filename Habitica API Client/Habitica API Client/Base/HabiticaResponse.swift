//
//  HabiticaResponse.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

struct HabiticaResponse<T: Codable>: Codable {
    let data: T?
}
