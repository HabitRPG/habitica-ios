//
//  TogglePinnedItem.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class TogglePinnedItemCall: ResponseObjectCall<PinResponseProtocol, APIPinResponse> {
    public init(pinType: String, path: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        super.init(httpMethod: .GET, endpoint: "user/toggle-pinned-item/\(pinType)/\(path)", postData: nil, stubHolder: stubHolder)
    }
}
