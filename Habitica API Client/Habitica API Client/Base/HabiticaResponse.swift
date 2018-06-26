//
//  HabiticaResponse.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public class HabiticaResponse<T: Decodable>: Decodable {
    public var success: Bool = false
    public var data: T?
    
    public var error: String?
    public var message: String?
    public var userV: Int?
}
