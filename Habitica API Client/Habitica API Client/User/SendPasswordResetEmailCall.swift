//
//  SendPasswordResetEmailCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import FunkyNetwork
import ReactiveSwift

public class SendPasswordResetEmailCall: ResponseObjectCall<UserProtocol, APIUser> {
    public init(newPassword: String, oldPassword: String, confirmPassword: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        super.init(httpMethod: .POST, endpoint: "user/reset-password", postData: nil, stubHolder: stubHolder)
    }
}
