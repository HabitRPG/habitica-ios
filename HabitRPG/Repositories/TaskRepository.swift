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
    
    private let realm = try? Realm()
    
    public func retrieveTasks(returnBlock: @escaping () -> Void) {
        APIClient.retrieveTasks { (tasks) in
            try? self.realm?.write {
                self.realm?.add(tasks, update: true)
            }
        }
    }
}
