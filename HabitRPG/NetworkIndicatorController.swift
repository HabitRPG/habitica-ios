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
        if IOSNetworkIndicatorController.networkCount == 0 {
            DispatchQueue.main.async { self.showIndicator() }
        }
        IOSNetworkIndicatorController.networkCount += 1
    }
    
    public func endNetworking() {
        IOSNetworkIndicatorController.networkCount -= 1
        if IOSNetworkIndicatorController.networkCount == 0 {
            DispatchQueue.main.async { self.showIndicator() }
        } else if IOSNetworkIndicatorController.networkCount < 0 {
            IOSNetworkIndicatorController.networkCount = 0
        }
    }
    
    private func showIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func hideIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
