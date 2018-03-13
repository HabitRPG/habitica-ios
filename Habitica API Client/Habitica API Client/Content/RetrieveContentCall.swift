//
//  RetrieveContentCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import FunkyNetwork
import ReactiveSwift

public class RetrieveContentCall: ResponseObjectCall<ContentProtocol, APIContent> {
    public init(stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "content.json")) {
        super.init(httpMethod: .GET, endpoint: "content", postData: nil, stubHolder: stubHolder)
    }
}
