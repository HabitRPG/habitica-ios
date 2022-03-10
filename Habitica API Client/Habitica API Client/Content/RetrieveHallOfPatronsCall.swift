//
//  RetrieveHallOfPatronsCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 11.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveHallOfPatronsCall: ResponseArrayCall<MemberProtocol, APIMember> {
    public init() {
        super.init(httpMethod: .GET, endpoint: "hall/patrons", needsAuthentication: false, ignoreEtag: true)
    }
}
