//
//  FallExtraGemsPromotion.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.08.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//


import UIKit

class ExtraGemsPromotion: HabiticaPromotion {

    let identifier: String
    var promoType: HabiticaPromotionType = .gemsAmount
    var isWebPromo: Bool = false
    var startDate: Date
    var endDate: Date
    
    // Optimize: Reuse DateFormatter instance to avoid expensive creation
    private lazy var shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    private lazy var fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        return formatter
    }()
    
    init(identifier: String, startDate: Date?, endDate: Date?) {
        self.identifier = identifier
        self.startDate = startDate ?? Date.with(year: 2020, month: 9, day: 22, timezone: TimeZone(abbreviation: "UTC"))
        self.endDate = endDate ?? Date.with(year: 2020, month: 9, day: 30, timezone: TimeZone(abbreviation: "UTC"))
    }
    
    var backgroundColor: UIColor {
        return UIColor.gray10
    }

    var buttonBackground: UIColor {
        return UIColor.orange50
    }
    
    var gradientStart: UIColor? {
        return nil
    }
    var gradientEnd: UIColor? {
        return nil
    }
    
    func makeGradient(view: UIView) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        return gradient
    }
    
    func configurePill(_ pillView: PillView) {
        pillView.backgroundColor = nil
        pillView.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let gradientLayer = makeGradient(view: pillView)
        gradientLayer.cornerRadius = pillView.frame.size.height / 2
        pillView.layer.insertSublayer(gradientLayer, at: 0)
        pillView.textColor = .white
    }
    
    func configurePromoMenuView(view: PromoMenuView) {
        view.leftImageView.image = Asset.extraGemsPromoMenuLeft.image
        view.rightImageView.image = Asset.extraGemsPromoMenuRight.image
        view.setTitleImage(Asset.fallPromoTitle.image)
        view.descriptionView.text = L10n.xToY(shortDateFormatter.string(from: startDate), shortDateFormatter.string(from: endDate)).uppercased()
        view.actionButton.backgroundColor = UIColor.gray50
        view.actionButton.setTitle(L10n.learnMore, for: .normal)
    }
    
    func configurePurchaseBanner(view: PromoBannerView) {
        view.backgroundColor = backgroundColor
        view.leftImageView.image = Asset.extraGemsPromoBannerLeft.image
        view.rightImageView.image = Asset.extraGemsPromoBannerRight.image
        view.setTitleImage(Asset.fallPromoTitle.image)
        view.descriptionLabel.textColor = UIColor("#FEDEAD")
        view.setDescription(L10n.xToY(shortDateFormatter.string(from: startDate), shortDateFormatter.string(from: endDate)).uppercased())
    }
    
    func configureGemView(view: GemPurchaseCell, regularAmount: Int) {
        view.backgroundColor = backgroundColor
        view.priceLabel.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let gradientLayer = makeGradient(view: view.priceLabel)
        gradientLayer.cornerRadius = UIConstants.mediumCornerRadius
        view.priceLabel.backgroundColor = .clear
        view.priceLabelBackground.layer.insertSublayer(gradientLayer, at: 0)
        view.priceLabel.textColor = .white
        view.footerLabel.text = L10n.usuallyXGems(regularAmount)
        view.footerLabel.textColor = UIColor("#CAC7CE")
        view.footerLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 12)
        view.circleView.backgroundColor = .gray50
        switch regularAmount {
        case 4:
            view.setGemAmount(5)
        case 21:
            view.setGemAmount(30)
        case 42:
            view.setGemAmount(60)
        case 84:
            view.setGemAmount(125)
        default:
            break
        }
        view.amountLabel.textColor = UIColor("#FEDEAD")
    }
    
    func configureInfoView(_ viewController: PromotionInfoViewController) {
        viewController.promoBanner.backgroundColor = backgroundColor
        viewController.promoBanner.leftImageView.image = Asset.extraGemsPromoInfoLeft.image
        viewController.promoBanner.rightImageView.image = Asset.extraGemsPromoInfoRight.image
        viewController.promoBanner.setTitleImage(Asset.fallPromoTitle.image)
        viewController.promoBanner.setDescription(L10n.limitedEvent.uppercased())
        viewController.promoBanner.descriptionLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 12)
        viewController.promoBanner.descriptionLabel.textColor = UIColor("#FEDEAD")
        viewController.promoBanner.durationLabel.textColor = .white
        viewController.promoBanner.durationLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15, ofWeight: .semibold)
        viewController.promoBanner.setDuration(L10n.xToY(shortDateFormatter.string(from: startDate), shortDateFormatter.string(from: endDate)))
        
        viewController.promptLabel.textColor = .white
        viewController.promptButton.setTitle(L10n.viewGemBundles, for: .normal)
        viewController.promptButton.setTitleColor(.white, for: .normal)
        viewController.promptButton.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let gradientLayer = makeGradient(view: viewController.promptButton)
        viewController.promptButton.layer.insertSublayer(gradientLayer, at: 0)
        viewController.instructionsDescription = L10n.GemsPromo.infoInstructions(shortDateFormatter.string(from: startDate), shortDateFormatter.string(from: endDate))
        viewController.limitationsDescription = L10n.GemsPromo.infoLimitations(fullDateFormatter.string(from: startDate), fullDateFormatter.string(from: endDate))
    }
}
