//
//  CreateTaskCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 26.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class CreateChallengeTaskCall: ResponseObjectCall<TaskProtocol, APITask> {
    public init(challengeID: String, task: TaskProtocol) {
        let encoder = JSONEncoder()
        encoder.setHabiticaDateEncodingStrategy()
        let json = try? encoder.encode(APITask(task))
        super.init(httpMethod: .POST, endpoint: "tasks/challenge/\(challengeID)", postData: json)
    }
}
