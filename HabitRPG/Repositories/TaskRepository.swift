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
        let headers: HTTPHeaders = [
            "x-api-user": AuthenticationManager.shared.currentUserId ?? "",
            "x-api-key": AuthenticationManager.shared.currentUserKey ?? "",
            "Accept": "application/json"
        ]
        Alamofire.request("https://habitica.com/api/v3/tasks/user", headers:headers).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var tasks = [Task]()
                for (_, taskJSON):(String, JSON) in json["data"] {
                    tasks.append(Task(json: taskJSON))
                }
                try? self.realm?.write {
                    self.realm?.add(tasks, update: true)
                }
            case .failure(let error):
                print(error)
            }
            
            returnBlock()
        }
    }
}
