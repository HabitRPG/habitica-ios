//
//  ScoreTaskCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class ScoreTaskCall: ResponseObjectCall<TaskResponseProtocol, TaskResponse> {
    public init(task: TaskProtocol, direction: TaskScoringDirection, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "tasks.json")) {
        super.init(httpMethod: .POST, endpoint: "tasks/\(task.id ?? "")/score/\(direction.rawValue)", stubHolder: stubHolder)
    }
}
