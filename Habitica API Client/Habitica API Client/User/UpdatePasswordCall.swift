//
//  UpdatePasswordCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class UpdatePasswordCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(newPassword: String, oldPassword: String, confirmPassword: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let json = try? JSONSerialization.data(withJSONObject: ["newPassword": newPassword, "password": oldPassword, "confirmPassword": confirmPassword], options: .prettyPrinted)
        super.init(httpMethod: .PUT, endpoint: "user/auth/update-password", postData: json, stubHolder: stubHolder)
    }
}
