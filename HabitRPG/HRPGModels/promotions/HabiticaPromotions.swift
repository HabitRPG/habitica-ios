//
//  HabiticaPromotions.swift
//  Habitica
//
//  Created by Phillip Thelen on 01.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import UIKit

public enum HabiticaPromotionType {
    case gemsAmount
    case gemsPrice
    case subscription
    
    static func getPromoFromKey(key: String) -> HabiticaPromotion? {
        switch key {
        case "fall_extra_gems":
            return FallExtraGemsPromotion()
        case "spooky_extra_gems":
            return SpookyExtraGemsPromotion()
        default:
            return nil
        }
    }
}

protocol HabiticaPromotion {
    var identifier: String { get }
    var promoType: HabiticaPromotionType { get }
    
    var startDate: Date { get }
    var endDate: Date { get }
    
    func backgroundColor() -> UIColor
    func buttonBackground() -> UIColor
    
    func configurePill(_ pillView: PillView)
    func configurePromoMenuView(view: PromoMenuView)
    func configurePurchaseBanner(view: PromoBannerView)
    func configureGemView(view: GemPurchaseCell, regularAmount: Int)
    func configureInfoView(_ viewController: PromotionInfoViewController)
}

class FallExtraGemsPromotion: HabiticaPromotion {

    var identifier = "fall_extra_gems"
    var promoType: HabiticaPromotionType = .gemsAmount
    
    var startDate: Date = Date.with(year: 2020, month: 9, day: 22, timezone: TimeZone(abbreviation: "UTC"))
    
    var endDate: Date = Date.with(year: 2020, month: 9, day: 30, timezone: TimeZone(abbreviation: "UTC"))
    
    func backgroundColor() -> UIColor {
        return UIColor.gray10
    }

    func buttonBackground() -> UIColor {
        return UIColor.orange50
    }
    
    private func makeGradient(view: UIView) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()

        gradient.colors = [UIColor("#FF6165").cgColor, UIColor("#FA8537").cgColor, UIColor("#FFB445").cgColor]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height)
        return gradient
    }
    
    func configurePill(_ pillView: PillView) {
        pillView.backgroundColor = nil
        pillView.layer.sublayers?.filter { $0 is CAGradientLayer}.forEach { $0.removeFromSuperlayer() }
        let gradientLayer = makeGradient(view: pillView)
        gradientLayer.cornerRadius = pillView.frame.size.height / 2
        pillView.layer.insertSublayer(gradientLayer, at: 0)
        pillView.textColor = .white
    }
    
    func configurePromoMenuView(view: PromoMenuView) {
        view.backgroundColor = backgroundColor()
        view.leftImageView.image = Asset.fallPromoMenuLeft.image
        view.rightImageView.image = Asset.fallPromoMenuRight.image
        view.setTitleImage(Asset.fallPromoTitle.image)
        view.setDescriptionImage(Asset.fallPromoMenuDescription.image)
        view.actionButton.backgroundColor = UIColor.gray1
        view.actionButton.setTitle(L10n.learnMore, for: .normal)
    }
    
    func configurePurchaseBanner(view: PromoBannerView) {
        view.backgroundColor = backgroundColor()
        view.leftImageView.image = Asset.fallPromoBannerLeft.image
        view.rightImageView.image = Asset.fallPromoBannerRight.image
        view.setTitleImage(Asset.fallPromoTitleDate.image)
    }
    
    func configureGemView(view: GemPurchaseCell, regularAmount: Int) {
        view.backgroundColor = backgroundColor()
        let colors = [
            UIColor.red10,
            UIColor.blue50,
            UIColor.green50,
            UIColor.purple400,
            UIColor.yellow50
        ].shuffled()
        let decorationImage = HabiticaIcons.imageOfFallGemPromoBG(redGemColor: colors[0], greenGemColor: colors[1], blueGemColor: colors[2], purpleGemColor: colors[3])
        view.leftDecorationImageView.image = decorationImage
        view.rightDecorationImageView.image = decorationImage
        view.purchaseButton.tintColor = .clear
        view.purchaseButton.layer.sublayers?.filter { $0 is CAGradientLayer}.forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = makeGradient(view: view.purchaseButton)
        gradientLayer.cornerRadius = 8
        view.purchaseButton.layer.insertSublayer(gradientLayer, at: 0)
        view.footerLabel.text = L10n.usuallyXGems(regularAmount)
        view.footerLabel.textColor = UIColor("#CAC7CE")
        view.footerLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 12, ofWeight: .semibold)
        
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
        view.amountLabel.textColor = UIColor("#FEE2B6")
        view.gemsLabel.textColor = UIColor("#FEE2B6")
    }
    
    func configureInfoView(_ viewController: PromotionInfoViewController) {
        viewController.promoBanner.backgroundColor = backgroundColor()
        viewController.promoBanner.leftImageView.image = Asset.fallPromoInfoLeft.image
        viewController.promoBanner.rightImageView.image = Asset.fallPromoInfoRight.image
        viewController.promoBanner.setTitleImage(Asset.fallPromoTitle.image)
        viewController.promoBanner.setDescription(L10n.limitedEvent.uppercased())
        viewController.promoBanner.descriptionLabel.textColor = UIColor("#FEE2B6")
        viewController.promoBanner.durationLabel.textColor = .white
        viewController.promoBanner.durationLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 16)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        viewController.promoBanner.setDuration(L10n.xToY(formatter.string(from: startDate), formatter.string(from: endDate)))
        
        viewController.promptLabel.textColor = UIColor("#F78E2F")
        viewController.promptLabel.text = L10n.FallPromo.infoPrompt
        viewController.promptButton.setTitle(L10n.viewGemBundles, for: .normal)
        viewController.promptButton.setTitleColor(.white, for: .normal)
        viewController.promptButton.backgroundColor = buttonBackground()
        viewController.instructionsTitleLabel.text = L10n.promoInfoInstructionsTitle
        viewController.instructionsDescriptionLabel.text = L10n.FallPromo.infoInstructions
        viewController.limitationsTitleLabel.text = L10n.promoInfoInstructionsTitle
        viewController.limitationsDescriptionLabel.text = L10n.FallPromo.infoLimitations
    }
}

class SpookyExtraGemsPromotion: HabiticaPromotion {

    var identifier = "spooky_extra_gems"
    var promoType: HabiticaPromotionType = .gemsAmount
    
    var startDate: Date = Date.with(year: 2020, month: 10, day: 29, timezone: TimeZone(abbreviation: "UTC"))
     
    var endDate: Date = Date.with(year: 2020, month: 11, day: 2, timezone: TimeZone(abbreviation: "UTC"))
    
    func backgroundColor() -> UIColor {
        return .gray10
    }

    func buttonBackground() -> UIColor {
        return .orange50
    }
    
    func configurePill(_ pillView: PillView) {
        pillView.pillColor = .orange50
    }
    
    func configurePromoMenuView(view: PromoMenuView) {
        view.backgroundColor = backgroundColor()
        view.leftImageView.image = Asset.spookyPromoMenuLeft.image
        view.rightImageView.image = Asset.spookyPromoMenuRight.image
        view.setTitleImage(Asset.spookyPromoTitle.image)
        view.setDescriptionImage(Asset.spookyPromoMenuDescription.image)
        view.actionButton.backgroundColor = UIColor.gray1
        view.actionButton.setTitle(L10n.learnMore, for: .normal)
    }
    
    func configurePurchaseBanner(view: PromoBannerView) {
        view.backgroundColor = backgroundColor()
        view.leftImageView.image = Asset.spookyPromoBannerLeft.image
        view.rightImageView.image = Asset.spookyPromoBannerRight.image
        view.setTitleImage(Asset.spookyPromoTitleDate.image)
    }
    
    func configureGemView(view: GemPurchaseCell, regularAmount: Int) {
        view.backgroundColor = backgroundColor()
        let decorationImage = HabiticaIcons.imageOfSpookyGemPromoBG
        view.leftDecorationImageView.image = decorationImage
        view.rightDecorationImageView.image = decorationImage
        view.purchaseButton.tintColor = buttonBackground()
        view.footerLabel.text = L10n.usuallyXGems(regularAmount)
        view.footerLabel.textColor = UIColor("#CAC7CE")
        view.footerLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 12, ofWeight: .semibold)
        
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
        view.amountLabel.textColor = UIColor("#FEE2B6")
        view.gemsLabel.textColor = UIColor("#FEE2B6")
    }
    
    func configureInfoView(_ viewController: PromotionInfoViewController) {
        viewController.promoBanner.backgroundColor = backgroundColor()
        viewController.promoBanner.leftImageView.image = Asset.spookyPromoInfoLeft.image
        viewController.promoBanner.rightImageView.image = Asset.spookyPromoInfoRight.image
        viewController.promoBanner.setTitleImage(Asset.spookyPromoTitle.image)
        viewController.promoBanner.setDescription(L10n.limitedEvent.uppercased())
        viewController.promoBanner.descriptionLabel.textColor = UIColor("#FEE2B6")
        viewController.promoBanner.durationLabel.textColor = .white
        viewController.promoBanner.durationLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 16)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        viewController.promoBanner.setDuration(L10n.xToY(formatter.string(from: startDate), formatter.string(from: endDate)))
        
        viewController.promptLabel.textColor = UIColor("#F78E2F")
        viewController.promptLabel.text = L10n.SpookyPromo.infoPrompt
        viewController.promptButton.setTitle(L10n.viewGemBundles, for: .normal)
        viewController.promptButton.setTitleColor(.white, for: .normal)
        viewController.promptButton.backgroundColor = buttonBackground()
        viewController.instructionsTitleLabel.text = L10n.promoInfoInstructionsTitle
        viewController.instructionsDescriptionLabel.text = L10n.SpookyPromo.infoInstructions
        viewController.limitationsTitleLabel.text = L10n.promoInfoInstructionsTitle
        viewController.limitationsDescriptionLabel.text = L10n.SpookyPromo.infoLimitations
    }
}
