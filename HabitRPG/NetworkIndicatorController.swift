//
//  NetworkIndicatorController.swift
//  Habitica
//
//  Created by Phillip Thelen on 29.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_API_Client

class IOSNetworkIndicatorController: NetworkIndicatorController {
    static var networkCount = 0
    public func beginNetworking() {
        IOSNetworkIndicatorController.networkCount += 1
    }
    
    public func endNetworking() {
        IOSNetworkIndicatorController.networkCount -= 1
        if IOSNetworkIndicatorController.networkCount == 0 {
        } else if IOSNetworkIndicatorController.networkCount < 0 {
            IOSNetworkIndicatorController.networkCount = 0
        }
    }
}
