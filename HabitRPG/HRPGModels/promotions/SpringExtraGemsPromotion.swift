//
//  SpringExtraGemsPromotion.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.08.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//

import UIKit

class SpringExtraGemsPromotion: ExtraGemsPromotion {
    init(startDate: Date?, endDate: Date?) {
        super.init(identifier: "spring_extra_gems", startDate: startDate, endDate: endDate)
    }
    
    override func makeGradient(view: UIView) -> CAGradientLayer {
        let gradient = CAGradientLayer()

        gradient.colors = [UIColor("#77F4C7").cgColor, UIColor("#CDFF8E").cgColor, UIColor("#FFBE5D").cgColor]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height)
        return gradient
    }
    
    override func configureGemView(view: GemPurchaseCell, regularAmount: Int) {
        super.configureGemView(view: view, regularAmount: regularAmount)
        switch regularAmount {
        case 4:
            view.sparkleView.image = Asset.spring4Sparkle.image
        case 21:
            view.sparkleView.image = Asset.spring20Sparkle.image
        case 42:
            view.sparkleView.image = Asset.spring20Sparkle.image
        case 84:
            view.sparkleView.image = Asset.spring84Sparkle.image
        default:
            break
        }
    }
    
    override func configurePromoMenuView(view: PromoMenuView) {
        super.configurePromoMenuView(view: view)
        view.setTitleImage(Asset.springPromoTitle.image)
    }
    
    override func configurePurchaseBanner(view: PromoBannerView) {
        super.configurePurchaseBanner(view: view)
        view.setTitleImage(Asset.springPromoTitle.image)
    }
    
    override func configureInfoView(_ viewController: PromotionInfoViewController) {
        super.configureInfoView(viewController)
        viewController.promoBanner.descriptionLabel.textColor = UIColor("#D5C8FF")
        viewController.promptText = L10n.SpringPromo.infoPrompt
    }
}
