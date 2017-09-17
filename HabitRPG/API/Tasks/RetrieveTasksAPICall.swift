//
//  RetrieveTasksAPICall.swift
//  Habitica
//
//  Created by Phillip on 17.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation

class RetrieveTasksAPICall: BaseAPICall<[Task]> {
        
    override init() {
        super.init()
        self.relativeURL = "tasks/user"
    }
    
}
