//
//  UpdateEmailCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class UpdateEmailCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(newEmail: String, password: String) {
        var data = ["newEmail": newEmail]
        if !password.isEmpty {
            data["password"] = password
        }
        let json = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        super.init(httpMethod: .PUT, endpoint: "user/auth/update-email", postData: json)
    }
}
