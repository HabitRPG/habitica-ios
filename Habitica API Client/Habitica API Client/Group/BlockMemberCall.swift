//
//  BlockMemberCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 06.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class BlockMemberCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(userID: String) {
        super.init(httpMethod: .POST, endpoint: "user/block/\(userID)")
    }
}
