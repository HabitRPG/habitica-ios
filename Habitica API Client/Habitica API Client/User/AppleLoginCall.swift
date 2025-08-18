//
//  AppleLoginCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class AppleLoginCall: ResponseObjectCall<LoginResponseProtocol, APILoginResponse> {
    public init(identityToken: String, name: String, allowRegister: Bool = false) {
        let json = try? JSONSerialization.data(withJSONObject: ["id_token": identityToken,
                                                                "user": "{\"name\": \"\(name)\"}",
                                                                "allowRegister": allowRegister
        ], options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "user/auth/apple", postData: json, errorHandler: PrintNetworkErrorHandler(), needsAuthentication: false)
    }
}
