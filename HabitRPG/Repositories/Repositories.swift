//
//  Repositories.swift
//  Habitica
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
class Repositories: NSObject {
    
    @objc
    static func taskRepository() -> TaskRepositoryProtocol {
        return TaskRepository()
    }
    
}
