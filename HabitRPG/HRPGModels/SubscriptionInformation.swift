//
//  SubscriptionInformation.swift
//  Habitica
//
//  Created by Phillip Thelen on 16/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class SubscriptionInformation {

    static let titles: [String] = [
        NSLocalizedString("Buy gems with gold", comment: ""),
        NSLocalizedString("Exclusive monthly items", comment: ""),
        NSLocalizedString("Retain additional history entries", comment: ""),
        NSLocalizedString("Daily drop-caps doubled", comment: "")
    ]

    static let descriptions: [String] = [
        NSLocalizedString("Alexander the Merchant will sell you Gems at a cost of 20 gold per gem. His monthly shipments are initially capped at 25 Gems per month," +
            "but this cap increases by 5 Gems for every three months of consecutive subscription, up to a maximum of 50 Gems per month!", comment: ""),
        NSLocalizedString("Each month you will receive a unique cosmetic item for your avatar!\n\nPlus, for every three months of consecutive subscription, " +
            "the Mysterious Time Travelers will grant you access to historic (and futuristic!) cosmetic items.", comment: ""),
        NSLocalizedString("Makes completed To-Dos and task history available for longer.", comment: ""),
        NSLocalizedString("Double drop caps will let you receive more items from your completed tasks every day, helping you complete your stable faster!", comment: "")
    ]
}
