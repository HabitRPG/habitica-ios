//
//  InboxProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 03.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol InboxProtocol {
    var optOut: Bool { get set }
    var numberNewMessages: Int { get set }
    var messages: [InboxMessageProtocol] { get set }
}
