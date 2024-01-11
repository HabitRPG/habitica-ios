//
//  UnlockPathCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 24.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class UnlockCustomizationsCall: ResponseObjectCall<UserProtocol, APIUser> {
    public init(path: String) {
        super.init(httpMethod: .POST, endpoint: "user/unlock/?path=\(path)", postData: nil)
    }
}
