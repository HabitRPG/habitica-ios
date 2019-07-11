//
//  DeleteAccountCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class DeleteAccountCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(password: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let json = try? JSONSerialization.data(withJSONObject: ["password": password], options: .prettyPrinted)
        super.init(httpMethod: .DELETE, endpoint: "user", postData: json, stubHolder: stubHolder)
    }
}
