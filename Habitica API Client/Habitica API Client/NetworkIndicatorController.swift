//
//  NetworkIndicatorController.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 29.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol NetworkIndicatorController {
    func beginNetworking()
    func endNetworking()
}
