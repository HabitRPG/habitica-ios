//
//  SpookyExtraGemsPromotion.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.08.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//
import UIKit

class SpookyExtraGemsPromotion: ExtraGemsPromotion {
    init(startDate: Date?, endDate: Date?) {
        super.init(identifier: "spooky_extra_gems", startDate: startDate, endDate: endDate)
    }
    
    override var pinnedPillTitleImage: UIImage? { return Asset.spookyPromoTitle.image }
    override var pinnedPillLeftArt: UIImage? { return Asset.spookyPromoMenuSmall.image }
    override var pinnedPillArrowColor: UIColor { return .gray400 }
    
    override func makeGradient(view: UIView) -> CAGradientLayer {
        let gradient = CAGradientLayer()

        gradient.colors = [UIColor("#FF944C").cgColor, UIColor("#FF6D71").cgColor, UIColor("##925CF3").cgColor]
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
            view.sparkleView.image = Asset.spooky4Sparkle.image
        case 21:
            view.sparkleView.image = Asset.spooky20Sparkle.image
        case 42:
            view.sparkleView.image = Asset.spooky20Sparkle.image
        case 84:
            view.sparkleView.image = Asset.spooky84Sparkle.image
        default:
            break
        }
    }
    
    override func configurePromoMenuView(view: PromoMenuView) {
        super.configurePromoMenuView(view: view)
        view.leftImageView.image = Asset.spookyPromoMenuLeft.image
        view.rightImageView.image = Asset.spookyPromoMenuRight.image
        view.setTitleImage(Asset.spookyPromoTitle.image)
        view.durationView.textColor = UIColor("#D5C8FF")
    }
    
    override func configurePurchaseBanner(view: PromoBannerView) {
        super.configurePurchaseBanner(view: view)
        view.leftImageView.image = Asset.spookyPromoBannerLeft.image
        view.rightImageView.image = Asset.spookyPromoBannerRight.image
        view.setTitleImage(Asset.spookyPromoTitle.image)
    }
    
    override func configureInfoView(_ viewController: PromotionInfoViewController) {
        super.configureInfoView(viewController)
        viewController.promoBanner.descriptionLabel.textColor = UIColor("#D5C8FF")
        viewController.promptText = L10n.SpookyPromo.infoPrompt
    }
}
