//
//  UpdateTask.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 26.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class UpdateTaskCall: ResponseObjectCall<TaskProtocol, APITask> {
    public init(task: TaskProtocol) {
        let encoder = JSONEncoder()
        encoder.setHabiticaDateEncodingStrategy()
        let json = try? encoder.encode(APITask(task))
        super.init(httpMethod: .PUT, endpoint: "tasks/\(task.id ?? "")", postData: json)
    }
}
