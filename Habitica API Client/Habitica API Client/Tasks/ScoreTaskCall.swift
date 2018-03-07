//
//  ScoreTaskCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import FunkyNetwork

public enum TaskScoringDirection: String {
    case up
    case down
}

public class ScoreTaskCall: ResponseObjectCall<TaskResponse, TaskResponse> {
    public init(task: TaskProtocol, direction: TaskScoringDirection, configuration: ServerConfigurationProtocol = HRPGServerConfig.current, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "tasks.json")) {
        super.init(configuration: configuration, httpMethod: "POST", endpoint: "tasks/\(task.id ?? "")/score/\(direction.rawValue)", postData: nil, stubHolder: stubHolder)
    }
}
