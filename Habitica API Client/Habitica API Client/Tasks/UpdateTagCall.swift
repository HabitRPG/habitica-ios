//
//  UpdateTagCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class UpdateTagCall: ResponseObjectCall<TagProtocol, APITag> {
    public init(tag: TagProtocol, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "tasks.json")) {
        let encoder = JSONEncoder()
        encoder.setHabiticaDateEncodingStrategy()
        let json = try? encoder.encode(APITag(tag))
        super.init(httpMethod: .PUT, endpoint: "tags/\(tag.id ?? "")", postData: json, stubHolder: stubHolder)
    }
}
