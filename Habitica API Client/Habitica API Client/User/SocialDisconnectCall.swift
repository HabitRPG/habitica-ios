//
//  SocialDisconnectCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 23.11.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class SocialDisconnectCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(network: String) {
        super.init(httpMethod: .DELETE, endpoint: "user/auth/social/\(network)")
    }
}
