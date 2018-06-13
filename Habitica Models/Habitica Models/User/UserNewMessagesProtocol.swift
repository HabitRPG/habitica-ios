//
//  UserNewMessagesProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 13.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol UserNewMessagesProtocol {
    var id: String? { get set }
    var name: String? { get set }
    var hasNewMessages: Bool { get set }
}
