//
//  SocialLoginCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class SocialLoginCall: ResponseObjectCall<LoginResponseProtocol, APILoginResponse> {
    public init(userID: String, network: String, accessToken: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let json = try? JSONSerialization.data(withJSONObject: ["network": network, "authResponse": [
            "access_token": accessToken,
            "client_id": userID
            ]], options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "user/auth/social", postData: json, stubHolder: stubHolder)
        needsAuthentication = false
    }
}
