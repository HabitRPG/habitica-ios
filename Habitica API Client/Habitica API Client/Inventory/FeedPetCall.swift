//
//  FeedPetCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 17.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class FeedPetCall: ResponseObjectCall<Int, Int> {
    public init(pet: PetProtocol, food: FoodProtocol, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        super.init(httpMethod: .POST, endpoint: "user/feed/\(pet.key ?? "")/\(food.key ?? "")", postData: nil, stubHolder: stubHolder)
    }
}
