//
//  DeleteTaskCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 27.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class DeleteTaskCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(task: TaskProtocol, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "task.json")) {
        super.init(httpMethod: .DELETE, endpoint: "tasks/\(task.id ?? "")", stubHolder: stubHolder)
    }
}
