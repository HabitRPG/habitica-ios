//
//  SendPasswordResetEmailCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class SendPasswordResetEmailCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(email: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let json = try? JSONSerialization.data(withJSONObject: ["email": email ], options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "user/reset-password", postData: json, stubHolder: stubHolder)
    }
}
