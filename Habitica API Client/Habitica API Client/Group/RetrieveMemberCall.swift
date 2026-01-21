//
//  RetrieveMemberCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 11.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveMemberCall: ResponseObjectCall<MemberProtocol, APIMember> {
    public init(userID: String, fromHall: Bool = false, onError: ((NetworkError) -> Void)?) {
        let endpoint: String
        if fromHall {
            endpoint = "hall/heroes/\(userID)"
        } else {
            if UUID(uuidString: userID) != nil {
                endpoint = "members/\(userID)"
            } else {
                endpoint = "members/username/\(userID)"
            }
        }
        var errorHandler: NetworkErrorHandler?
        if let action = onError {
            errorHandler = CallbackNetworkErrorHandler(onError: action)
        }
        super.init(httpMethod: .GET, endpoint: endpoint, errorHandler: errorHandler)
    }
}
