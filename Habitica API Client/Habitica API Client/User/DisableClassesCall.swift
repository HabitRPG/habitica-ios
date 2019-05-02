//
//  OptOutOfClassCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 27.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class DisableClassesCall: ResponseObjectCall<UserProtocol, APIUser> {
    public init(stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        super.init(httpMethod: .POST, endpoint: "user/disable-classes", stubHolder: stubHolder)
    }
}
