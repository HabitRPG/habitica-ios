//
//  TaskRepository.swift
//  Habitica
//
//  Created by Phillip on 10.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import SwiftyJSON

class TaskRepository: NSObject {
    
    let localRepository = TaskLocalRepository()
    
    public func retrieveTasks(returnBlock: @escaping () -> Void) {
        RetrieveTasksAPICall().execute { (result) in
            if let tasks = result {
                self.localRepository.save(objects: tasks)
            }
            returnBlock()
        }
    }
}
