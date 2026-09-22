//
//  Survey2021Promotion.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.08.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//
import UIKit

class Survey2021Promotion: HabiticaWebPromotion {
    var identifier = "survey2021"
    var promoType: HabiticaPromotionType = .survey
    var isWebPromo: Bool = true
    var startDate: Date = Date()
    var endDate: Date = Date().addingTimeInterval(1000)
    
    var pinnedPillTitle: String? { return nil }
    var pinnedPillTitleImage: UIImage? { return nil }
    var pinnedPillLeftArt: UIImage? { return nil }
    var pinnedPillBackground: UIColor? { return backgroundColor }
    var pinnedPillArrowColor: UIColor { return .yellow500 }
    var pinnedPillArtHeight: CGFloat { return 40 }
    
    var url: URL?
    
    init(url: String?) {
        self.url = URL(string: url ?? "")
    }
    
    var backgroundColor: UIColor {
        return UIColor.blue1
    }

    var buttonBackground: UIColor {
        return ThemeService.shared.theme.contentBackgroundColor
    }
    
    var gradientStart: UIColor? {
        return nil
    }
    
    var gradientEnd: UIColor? {
        return nil
    }
    
    func configurePill(_ pillView: PillView) {
    }
    
    func configurePromoMenuView(view: PromoMenuView) {
        view.canClose = true
        view.leftImageView.image = Asset.surveyArtLeft.image
        view.rightImageView.image = Asset.surveyArtRight.image
        view.setTitle(L10n.Survey.title)
        view.titleView.textColor = .white
        view.setDescription(L10n.Survey.description)
        view.descriptionView.textColor = .white
        view.actionButton.backgroundColor = .white
        view.actionButton.setTitle(L10n.Survey.button, for: .normal)
        view.actionButton.setTitleColor(.blue10, for: .normal)
        view.closeButton.tintColor = .blue100
    }
    
    func configurePurchaseBanner(view: PromoBannerView) {
    }
    
    func configureGemView(view: GemPurchaseCell, regularAmount: Int) {
    }
    
    func configureInfoView(_ viewController: PromotionInfoViewController) {
    }
}
