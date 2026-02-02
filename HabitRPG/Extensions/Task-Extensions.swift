//
//  Task-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.01.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//

import Habitica_Models

extension TaskProtocol {
    var isOfficial: Bool {
        return text == L10n.Tasks.Examples.todoText
    }
}
