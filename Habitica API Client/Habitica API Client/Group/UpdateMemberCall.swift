//
//  UpdateMemberCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.12.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class UpdateMemberCall: ResponseObjectCall<MemberProtocol, APIMember> {
    public init(userID: String, updateDict: [String: Encodable]) {
        let json = try? JSONSerialization.data(withJSONObject: updateDict, options: .prettyPrinted)
        super.init(httpMethod: .PUT, endpoint: "hall/heroes/\(userID)", postData: json)
    }
}
