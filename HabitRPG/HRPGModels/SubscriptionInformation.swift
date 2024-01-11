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
        L10n.subscriptionInfo1Title,
        L10n.Subscription.infoArmoireTitle,
        L10n.subscriptionInfo2Title,
        L10n.subscriptionInfo3Title,
        L10n.Subscription.infoFaintTitle,
        L10n.subscriptionInfo4Title,
        L10n.subscriptionInfo5Title
    ]

    static let descriptions: [String] = [
        L10n.subscriptionInfo1Description,
        L10n.Subscription.infoArmoireDescription,
        L10n.subscriptionInfo2Description,
        L10n.subscriptionInfo3Description,
        L10n.Subscription.infoFaintDescription,
        L10n.subscriptionInfo4Description,
        L10n.subscriptionInfo5Description
    ]
    
    static let images: [UIImage?] = [
        Asset.subBenefitsGems.image,
        Asset.subBenefitsArmoire.image,
        Asset.subBenefitsHourglasses.image,
        nil,
        Asset.subBenefitsFaint.image,
        Asset.subBenefitsPet.image,
        Asset.subBenefitDrops.image
    ]
}
