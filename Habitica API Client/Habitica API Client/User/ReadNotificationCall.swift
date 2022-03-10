//
//  ReadNotificationCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 03.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class ReadNotificationCall: ResponseArrayCall<NotificationProtocol, APINotification> {
    public init(notificationID: String) {
        super.init(httpMethod: .POST, endpoint: "notifications/\(notificationID)/read", postData: nil)
    }
}
