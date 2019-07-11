//
//  CreateTasksCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class CreateTasksCall: ResponseArrayCall<TaskProtocol, APITask> {
    public init(tasks: [TaskProtocol], stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "tasks.json")) {
        let encoder = JSONEncoder()
        encoder.setHabiticaDateEncodingStrategy()
        let json = try? encoder.encode(tasks.map({ (task) in
            return APITask(task)
        }))
        super.init(httpMethod: .POST, endpoint: "tasks/user", postData: json, stubHolder: stubHolder)
    }
}
