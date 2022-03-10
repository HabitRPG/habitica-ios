//
//  SelectClassCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 27.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class SelectClassCall: ResponseObjectCall<UserProtocol, APIUser> {
    public init(class habiticaClass: HabiticaClass?) {
        var url = "user/change-class"
        if let habiticaClass = habiticaClass {
            url += "?class=\(habiticaClass.rawValue)"
        }
        super.init(httpMethod: .POST, endpoint: url)
    }
}
