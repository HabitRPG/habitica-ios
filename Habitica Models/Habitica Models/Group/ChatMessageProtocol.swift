//
//  ChatMessageProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 29.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol ChatMessageProtocol {
    var id: String? { get set }
    var userID: String? { get set }
    var text: String? { get set }
    var attributedText: NSAttributedString? { get set }
    var timestamp: Date? { get set }
    var username: String? { get set }
    var flagCount: Int { get set }
    var contributor: ContributorProtocol? { get set }
    var likes: [ChatMessageReactionProtocol] { get set }
    var flags: [ChatMessageReactionProtocol] { get set }
    var userStyles: UserStyleProtocol? { get set }
    
    var isValid: Bool { get }
}
