//
//  ChallengeProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 24.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol ChallengeProtocol {
    var id: String? { get set }
    var name: String? { get set }
    var notes: String? { get set }
    var summary: String? { get set }
    var official: Bool { get set }
    var prize: Int { get set }
    var shortName: String? { get set }
    var updatedAt: Date? { get set }
    var leaderID: String? { get set }
    var leaderName: String? { get set }
    var groupID: String? { get set }
    var groupName: String? { get set }
    var groupPrivacy: String? { get set }
    var memberCount: Int { get set }
    var createdAt: Date? { get set }
    var categories: [ChallengeCategoryProtocol] { get set }
    var tasksOrder: [String: [String]] { get set }
    var habits: [TaskProtocol] { get }
    var dailies: [TaskProtocol] { get }
    var todos: [TaskProtocol] { get }
    var rewards: [TaskProtocol] { get }
}
