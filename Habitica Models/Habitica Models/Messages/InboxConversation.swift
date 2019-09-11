//
//  InboxConversation.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 11.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol InboxConversationProtocol: BaseModelProtocol {
    var uuid: String { get set }
    var username: String? { get set }
    var displayName: String? { get set }
    var timestamp: Date? { get set }
    var contributor: ContributorProtocol? { get set }
    var userStyles: UserStyleProtocol? { get set }
    var text: String? { get set }
}
