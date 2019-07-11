//
//  MoveTaskCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 27.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class MoveTaskCall: ResponseArrayCall<String, String> {
    public init(task: TaskProtocol, toPosition: Int, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "tasks.json")) {
        super.init(httpMethod: .POST, endpoint: "tasks/\(task.id ?? "")/move/to/\(toPosition)", stubHolder: stubHolder)
    }
}
