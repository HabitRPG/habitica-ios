//
//  RetrieveShopInventoryCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveShopInventoryCall: ResponseObjectCall<ShopProtocol, APIShop> {
    public init(identifier: String, language: String? = nil, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        var shopIdentifier = identifier
        switch identifier {
        case Constants.QuestShopKey:
            shopIdentifier = "quests"
        case Constants.SeasonalShopKey:
            shopIdentifier = "seasonal"
        case Constants.TimeTravelersShopKey:
            shopIdentifier = "time-travelers"
        default:
            shopIdentifier = identifier
        }
        let url = language != nil ? "shops/\(shopIdentifier)?language=\(language ?? "")" : "shops/\(shopIdentifier)"
        super.init(httpMethod: .GET, endpoint: url, postData: nil, stubHolder: stubHolder)
    }
}
