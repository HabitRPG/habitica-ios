//
//  CancelSubscribeCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 04.11.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class CancelSubscribeCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init() {
        super.init(httpMethod: .GET, endpoint: "iap/ios/subscribe/cancel")
    }
}
