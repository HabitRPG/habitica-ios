//
//  TaskType-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

extension TaskType {
    func prettName() -> String{
        switch self {
        case .habit:
            return L10n.Tasks.habit
        case .daily:
            return L10n.Tasks.daily
        case .todo:
            return L10n.Tasks.todo
        case .reward:
            return L10n.Tasks.reward
        default:
            return ""
        }
    }
}
