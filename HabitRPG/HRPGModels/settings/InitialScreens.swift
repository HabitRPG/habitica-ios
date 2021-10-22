//
//  InitialScreens.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.10.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation

enum InitialScreens: String {
    case habits = "/user/tasks/habit"
    case dailies = "/user/tasks/daily"
    case todos = "/user/tasks/todo"
    case rewards = "/user/tasks/reward"
    case menu = "/menu"
    case party = "/party"
    
    var niceName: String {
        switch self {
        case .habits:
            return L10n.Tasks.habits
        case .dailies:
            return L10n.Tasks.dailies
        case .todos:
            return L10n.Tasks.todos
        case .rewards:
            return L10n.Tasks.rewards
        case .menu:
            return L10n.menu
        case .party:
            return L10n.Titles.party
        }
    }
    
    static var allScreens: [InitialScreens] {
        return [
            .habits,
            .dailies,
            .todos,
            .rewards,
            .menu,
            .party
        ]
    }
}
