//
//  InboxMessageProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 03.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol InboxMessageProtocol {
    @objc var id: String? { get set }
    @objc var userID: String? { get set }
    @objc var contributor: ContributorProtocol? { get set }
    @objc var timestamp: Date? { get set }
    @objc var likes: [ChatMessageReactionProtocol] { get set }
    @objc var flags: [ChatMessageReactionProtocol] { get set }
    @objc var text: String? { get set }
    @objc var attributedText: NSAttributedString? { get set }
    @objc var sent: Bool { get set }
    @objc var sort: Int { get set }
    @objc var displayName: String? { get set }
    @objc var username: String? { get set }
    @objc var flagCount: Int { get set }
    @objc var userStyles: UserStyleProtocol? { get set }
}
