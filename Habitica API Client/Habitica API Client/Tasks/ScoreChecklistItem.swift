//
//  ScoreChecklistItem.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 30.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class ScoreChecklistItem: ResponseObjectCall<TaskProtocol, APITask> {
    public init(item: ChecklistItemProtocol, task: TaskProtocol, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "tasks.json")) {
        super.init(httpMethod: .POST, endpoint: "tasks/\(task.id ?? "")/checklist/\(item.id ?? "")/score", stubHolder: stubHolder)
    }
}
