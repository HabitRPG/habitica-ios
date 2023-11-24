//
//  FlagMemberCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 24.11.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class FlagMemberCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(memberID: String, data: [String: Any]) {
        let json = try? JSONSerialization.data(withJSONObject: data)
        super.init(httpMethod: .POST, endpoint: "members/\(memberID)/flag", postData: json)
    }
}
