//
//  UnlinkAllTasksCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 10.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class UnlinkAllTasksCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(challengeID: String, keepOption: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "tasks.json")) {
        super.init(httpMethod: .POST, endpoint: "tasks/unlink-all/\(challengeID)?keep=\(keepOption)", stubHolder: stubHolder)
    }
}
