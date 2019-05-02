//
//  UpdateGroupCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 10.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class UpdateGroupCall: ResponseObjectCall<GroupProtocol, APIGroup> {
    public init(group: GroupProtocol, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "group.json")) {
        let encoder = JSONEncoder()
        encoder.setHabiticaDateEncodingStrategy()
        let json = try? encoder.encode(APIGroup(group))
        super.init(httpMethod: .PUT, endpoint: "groups/\(group.id ?? "")", postData: json, stubHolder: stubHolder)
    }
}
