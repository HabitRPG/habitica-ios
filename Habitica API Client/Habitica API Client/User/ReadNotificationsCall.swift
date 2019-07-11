//
//  ReadNotificationsCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 03.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class ReadNotificationsCall: ResponseArrayCall<NotificationProtocol, APINotification> {
    public init(notificationIDs: [String], stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let obj = ["notificationIds": notificationIDs]
        let json = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "notifications/read", postData: json, stubHolder: stubHolder)
    }
}
