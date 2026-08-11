//
//  HabiticaPromotions.swift
//  Habitica
//
//  Created by Phillip Thelen on 01.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import UIKit

enum HabiticaPromotions: String, Identifiable {
    var id: RawValue { rawValue }
    
    case springExtraGems
    case summerExtraGems
    case fallExtraGems
    case winterExtraGems
    case flashExtraGems
    case spookyExtraGems
    case g1g1Sale
    
    var niceName: String {
        switch self {
        case .springExtraGems:
            return "Spring Extra Gems"
        case .summerExtraGems:
            return "Summer Extra Gems"
        case .fallExtraGems:
            return "Fall Extra Gems"
        case .spookyExtraGems:
            return "Spooky Extra Gems"
        case .winterExtraGems:
            return "Winter Extra Gems"
        case .flashExtraGems:
            return "Flash Extra Gems"
        case .g1g1Sale:
            return "Gift One Get One Sale"
        }
    }
    
    static var all: [HabiticaPromotions] {
        return [
            .springExtraGems,
            .summerExtraGems,
            .fallExtraGems,
            .spookyExtraGems,
            .flashExtraGems
        ]
    }
}


protocol HabiticaPromotion {
    var identifier: String { get }
    var promoType: HabiticaPromotionType { get }
    var isWebPromo: Bool { get }
    
    var startDate: Date { get }
    var endDate: Date { get }
    
    var backgroundColor: UIColor { get }
    var gradientStart: UIColor? { get }
    var gradientEnd: UIColor? { get }
    var buttonBackground: UIColor { get }
    
    func configurePill(_ pillView: PillView)
    func configurePromoMenuView(view: PromoMenuView)
    func configurePurchaseBanner(view: PromoBannerView)
    func configureGemView(view: GemPurchaseCell, regularAmount: Int)
    func configureInfoView(_ viewController: PromotionInfoViewController)
}
