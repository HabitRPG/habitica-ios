//
//  DeleteTagCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class DeleteTagCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(tag: TagProtocol, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "task.json")) {
        super.init(httpMethod: .DELETE, endpoint: "tags/\(tag.id ?? "")", stubHolder: stubHolder)
    }
}
