//
//  AuthenticationManager.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public class NetworkAuthenticationManager {
    
    public static let shared = NetworkAuthenticationManager()
    
    public var currentUserId: String?
    public var currentUserKey: String?
    
}
