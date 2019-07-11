//
//  UseTransformationItemCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 11.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class UseTransformationItemCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(item: SpecialItemProtocol, target: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let url = "user/class/cast/\(item.key ?? "")?targetType=user&targetId=\(target)"
        super.init(httpMethod: .POST, endpoint: url, stubHolder: stubHolder)
    }
}
