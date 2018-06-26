//
//  RetrieveShopInventoryCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import FunkyNetwork
import ReactiveSwift

public class RetrieveShopInventoryCall: ResponseObjectCall<ShopProtocol, APIShop> {
    public init(identifier: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        var shopIdentifier = identifier
        switch identifier {
        case Shops.QuestShopKey:
            shopIdentifier = "quests"
        case Shops.SeasonalShopKey:
            shopIdentifier = "seasonal"
        case Shops.TimeTravelersShopKey:
            shopIdentifier = "time-travelers"
        default:
            shopIdentifier = identifier
        }
        super.init(httpMethod: .GET, endpoint: "shops/\(shopIdentifier)", postData: nil, stubHolder: stubHolder)
    }
}
