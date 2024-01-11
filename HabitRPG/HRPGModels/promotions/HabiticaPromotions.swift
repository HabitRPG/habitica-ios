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
    case survey
    
    static func getPromoFromKey(key: String, startDate: Date?, endDate: Date?) -> HabiticaPromotion? {
        switch key {
        case "fall_extra_gems", "fall2020", "testfall2020":
            return FallExtraGemsPromotion(startDate: startDate, endDate: endDate)
        case "spooky_extra_gems", "fall2020SecondPromo", "testfall2020SecondPromo":
            return SpookyExtraGemsPromotion(startDate: startDate, endDate: endDate)
        case "g1g1":
            return GiftOneGetOnePromotion(startDate: startDate, endDate: endDate)
        case "survey2021":
            let url = ConfigRepository.shared.string(variable: .surveyURL)
            return Survey2021Promotion(url: url)
        default:
            return nil
        }
    }
}

protocol HabiticaPromotion {
    var identifier: String { get }
    var promoType: HabiticaPromotionType { get }
    var isWebPromo: Bool { get }
    
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

protocol HabiticaWebPromotion: HabiticaPromotion {
    var url: URL? { get }
}

class FallExtraGemsPromotion: HabiticaPromotion {

    var identifier = "fall_extra_gems"
    var promoType: HabiticaPromotionType = .gemsAmount
    var isWebPromo: Bool = false
    var startDate: Date
    var endDate: Date
    
    init(startDate: Date?, endDate: Date?) {
        self.startDate = startDate ?? Date.with(year: 2020, month: 9, day: 22, timezone: TimeZone(abbreviation: "UTC"))
        self.endDate = endDate ?? Date.with(year: 2020, month: 9, day: 30, timezone: TimeZone(abbreviation: "UTC"))
    }
    
    func backgroundColor() -> UIColor {
        return UIColor.gray10
    }

    func buttonBackground() -> UIColor {
        return UIColor.orange50
    }
    
    private func makeGradient(view: UIView) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()

        gradient.colors = [UIColor("#FFB445").cgColor, UIColor("#FA8537").cgColor, UIColor("#FF6165").cgColor]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height)
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
        view.backgroundColor = backgroundColor()
        view.leftImageView.image = Asset.fallPromoMenuLeft.image
        view.rightImageView.image = Asset.fallPromoMenuRight.image
        view.setTitleImage(Asset.fallPromoTitle.image)
        view.setDescriptionImage(Asset.fallPromoMenuDescription.image)
        view.actionButton.backgroundColor = UIColor.gray50
        view.actionButton.setTitle(L10n.learnMore, for: .normal)
    }
    
    func configurePurchaseBanner(view: PromoBannerView) {
        view.backgroundColor = backgroundColor()
        view.leftImageView.image = Asset.fallPromoBannerLeft.image
        view.rightImageView.image = Asset.fallPromoBannerRight.image
        view.setTitleImage(Asset.fallPromoTitle.image)
        view.descriptionLabel.textColor = UIColor("#FEE2B6")
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        view.setDescription(L10n.xToY(formatter.string(from: startDate), formatter.string(from: endDate)).uppercased())
    }
    
    func configureGemView(view: GemPurchaseCell, regularAmount: Int) {
        view.backgroundColor = backgroundColor()
        view.priceLabel.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let gradientLayer = makeGradient(view: view.priceLabel)
        gradientLayer.cornerRadius = 8
        view.priceLabel.backgroundColor = .clear
        view.priceLabelBackground.layer.insertSublayer(gradientLayer, at: 0)
        view.priceLabel.textColor = .white
        view.footerLabel.text = L10n.usuallyXGems(regularAmount)
        view.footerLabel.textColor = UIColor("#CAC7CE")
        view.footerLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 12)
        switch regularAmount {
        case 4:
            view.setGemAmount(5)
            view.imageView.image = Asset._4GemsFall.image
        case 21:
            view.setGemAmount(30)
            view.imageView.image = Asset._21GemsFall.image
        case 42:
            view.setGemAmount(60)
            view.imageView.image = Asset._42GemsFall.image
        case 84:
            view.setGemAmount(125)
            view.imageView.image = Asset._84GemsFall.image
        default:
            break
        }
        view.amountLabel.textColor = UIColor("#FEE2B6")
    }
    
    func configureInfoView(_ viewController: PromotionInfoViewController) {
        viewController.promoBanner.backgroundColor = backgroundColor()
        viewController.promoBanner.leftImageView.image = Asset.fallPromoInfoLeft.image
        viewController.promoBanner.rightImageView.image = Asset.fallPromoInfoRight.image
        viewController.promoBanner.setTitleImage(Asset.fallPromoTitle.image)
        viewController.promoBanner.setDescription(L10n.limitedEvent.uppercased())
        viewController.promoBanner.descriptionLabel.textColor = UIColor("#FEE2B6")
        viewController.promoBanner.durationLabel.textColor = .white
        viewController.promoBanner.durationLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15, ofWeight: .semibold)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        viewController.promoBanner.setDuration(L10n.xToY(formatter.string(from: startDate), formatter.string(from: endDate)))
        
        viewController.promptLabel.textColor = UIColor("#F78E2F")
        viewController.promptText = L10n.FallPromo.infoPrompt
        viewController.promptButton.setTitle(L10n.viewGemBundles, for: .normal)
        viewController.promptButton.setTitleColor(.white, for: .normal)
        viewController.promptButton.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let gradientLayer = makeGradient(view: viewController.promptButton)
        gradientLayer.cornerRadius = 8
        viewController.promptButton.layer.insertSublayer(gradientLayer, at: 0)
        viewController.instructionsDescription = L10n.FallPromo.infoInstructions(formatter.string(from: startDate), formatter.string(from: endDate))
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        viewController.limitationsDescription = L10n.GemsPromo.infoLimitations(formatter.string(from: startDate), formatter.string(from: endDate))
    }
}

class SpookyExtraGemsPromotion: HabiticaPromotion {

    var identifier = "spooky_extra_gems"
    var promoType: HabiticaPromotionType = .gemsAmount
    var isWebPromo: Bool = false
    var startDate: Date
    var endDate: Date
    
    init(startDate: Date?, endDate: Date?) {
        self.startDate = startDate ?? Date.with(year: 2020, month: 10, day: 29, timezone: TimeZone(abbreviation: "UTC"))
        self.endDate = endDate ?? Date.with(year: 2020, month: 11, day: 2, timezone: TimeZone(abbreviation: "UTC"))
    }
    
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
        view.actionButton.backgroundColor = UIColor.gray10
        view.actionButton.setTitle(L10n.learnMore, for: .normal)
    }
    
    func configurePurchaseBanner(view: PromoBannerView) {
        view.backgroundColor = backgroundColor()
        view.leftImageView.image = Asset.spookyPromoBannerLeft.image
        view.rightImageView.image = Asset.spookyPromoBannerRight.image
        view.setTitleImage(Asset.spookyPromoTitle.image)
        view.descriptionLabel.textColor = UIColor("#FEE2B6")

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        view.setDescription(L10n.xToY(formatter.string(from: startDate), formatter.string(from: endDate)).uppercased())
    }
    
    func configureGemView(view: GemPurchaseCell, regularAmount: Int) {
        view.backgroundColor = backgroundColor()
        view.priceLabel.textColor = .white
        view.priceLabel.backgroundColor = buttonBackground()
        view.footerLabel.text = L10n.usuallyXGems(regularAmount)
        view.footerLabel.textColor = UIColor("#CAC7CE")
        view.footerLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 12)
        
        switch regularAmount {
        case 4:
            view.setGemAmount(5)
            view.imageView.image = Asset._4GemsSpooky.image
        case 21:
            view.setGemAmount(30)
            view.imageView.image = Asset._21GemsSpooky.image
        case 42:
            view.setGemAmount(60)
            view.imageView.image = Asset._42GemsSpooky.image
        case 84:
            view.setGemAmount(125)
            view.imageView.image = Asset._84GemsSpooky.image
        default:
            break
        }
        view.amountLabel.textColor = UIColor("#FEE2B6")
    }
    
    func configureInfoView(_ viewController: PromotionInfoViewController) {
        viewController.promoBanner.backgroundColor = backgroundColor()
        viewController.promoBanner.leftImageView.image = Asset.spookyPromoInfoLeft.image
        viewController.promoBanner.rightImageView.image = Asset.spookyPromoInfoRight.image
        viewController.promoBanner.setTitleImage(Asset.spookyPromoTitle.image)
        viewController.promoBanner.setDescription(L10n.limitedEvent.uppercased())
        viewController.promoBanner.descriptionLabel.textColor = UIColor("#FEE2B6")
        viewController.promoBanner.durationLabel.textColor = .white
        viewController.promoBanner.durationLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15, ofWeight: .semibold)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        viewController.promoBanner.setDuration(L10n.xToY(formatter.string(from: startDate), formatter.string(from: endDate)))
        
        viewController.promptLabel.textColor = UIColor("#F78E2F")
        viewController.promptText = L10n.SpookyPromo.infoPrompt
        viewController.promptButton.setTitle(L10n.viewGemBundles, for: .normal)
        viewController.promptButton.setTitleColor(.white, for: .normal)
        viewController.promptButton.backgroundColor = buttonBackground()
        viewController.instructionsDescription = L10n.SpookyPromo.infoInstructions(formatter.string(from: startDate), formatter.string(from: endDate))
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        viewController.limitationsDescription = L10n.GemsPromo.infoLimitations(formatter.string(from: startDate), formatter.string(from: endDate))
    }
}

class GiftOneGetOnePromotion: HabiticaPromotion {

    var identifier = "g1g1"
    var promoType: HabiticaPromotionType = .subscription
    var isWebPromo: Bool = false
    var startDate: Date
    var endDate: Date
    
    init(startDate: Date?, endDate: Date?) {
        self.startDate = startDate ?? Date.with(year: 2020, month: 12, day: 17, timezone: TimeZone(abbreviation: "UTC"))
        self.endDate = endDate ?? Date.with(year: 2021, month: 1, day: 7, timezone: TimeZone(abbreviation: "UTC"))
    }
    
    func backgroundColor() -> UIColor {
        return UIColor.gray10
    }

    func buttonBackground() -> UIColor {
        return ThemeService.shared.theme.contentBackgroundColor
    }
    
    private func makeGradient(view: UIView) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()

        gradient.colors = [UIColor("#3BCAD7").cgColor, UIColor("#925CF3").cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height)
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
        view.backgroundColor = nil
        view.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let gradientLayer = makeGradient(view: view)
        view.layer.insertSublayer(gradientLayer, at: 0)
        view.leftImageView.image = Asset.promoGiftLeftLarge.image
        view.rightImageView.image = Asset.promoGiftRightLarge.image
        view.setTitle(L10n.giftOneGetOneEvent)
        view.titleView.textColor = .white
        view.setDescription(L10n.giftOneGetOneDescription)
        view.descriptionView.textColor = .white
        view.actionButton.backgroundColor = buttonBackground()
        view.actionButton.setTitle(L10n.learnMore, for: .normal)
        if ThemeService.shared.theme.isDark {
            view.actionButton.setTitleColor(UIColor.teal100, for: .normal)
        } else {
            view.actionButton.setTitleColor(UIColor.teal10, for: .normal)
        }
    }
    
    func configurePurchaseBanner(view: PromoBannerView) {
        view.backgroundColor = nil
        view.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let gradientLayer = makeGradient(view: view)
        view.layer.insertSublayer(gradientLayer, at: 0)
        view.leftImageView.image = Asset.subScreenG1g1PresentsLeft.image
        view.rightImageView.image = Asset.subScreenG1g1PresentsRight.image
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        view.setTitle(L10n.GiftOneGetOneData.purchaseBannerTitle(formatter.string(from: endDate)))
        view.titleView.textColor = .white
        view.titleView.font = .systemFont(ofSize: 17, weight: .semibold)
    }
    
    func configureGemView(view: GemPurchaseCell, regularAmount: Int) {
    }
    
    func configureInfoView(_ viewController: PromotionInfoViewController) {
        viewController.promoBanner.backgroundColor = nil
        viewController.promoBanner.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let gradientLayer = makeGradient(view: viewController.promoBanner)
        viewController.promoBanner.layer.insertSublayer(gradientLayer, at: 0)
        viewController.promoBanner.leftImageView.image = Asset.promoGiftsLeft.image
        viewController.promoBanner.rightImageView.image = Asset.promoGiftsRight.image
        viewController.promoBanner.setTitle(L10n.giftOneGetOneTitle)
        viewController.promoBanner.titleView.textColor = .white
        viewController.promoBanner.setDescription(L10n.limitedEvent.uppercased())
        viewController.promoBanner.descriptionLabel.textColor = .white
        viewController.promoBanner.durationLabel.textColor = .white
        viewController.promoBanner.durationLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15, ofWeight: .semibold)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        viewController.promoBanner.setDuration(L10n.xToY(formatter.string(from: startDate), formatter.string(from: endDate)))
        if ThemeService.shared.theme.isDark {
            viewController.promptLabel.textColor = UIColor.teal100
        } else {
            viewController.promptLabel.textColor = UIColor.teal10
        }
        viewController.promptText = L10n.GiftOneGetOneData.infoPrompt
        viewController.promptButton.setTitle(L10n.giftSubscription, for: .normal)
        viewController.promptButton.setTitleColor(.white, for: .normal)
        viewController.promptButton.backgroundColor = UIColor("#925CF3")
        viewController.instructionsDescription = L10n.GiftOneGetOneData.infoInstructions
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .medium
        timeFormatter.timeZone = TimeZone(identifier: "UTC")
        viewController.limitationsDescription = L10n.GiftOneGetOneData.infoLimitations(formatter.string(from: startDate), timeFormatter.string(from: startDate),
                                                                                       formatter.string(from: endDate), timeFormatter.string(from: endDate))
    }
}

class Survey2021Promotion: HabiticaWebPromotion {

    var identifier = "survey2021"
    var promoType: HabiticaPromotionType = .survey
    var isWebPromo: Bool = true
    var startDate: Date = Date()
    var endDate: Date = Date().addingTimeInterval(1000)
    
    var url: URL?
    
    init(url: String?) {
        self.url = URL(string: url ?? "")
    }
    
    func backgroundColor() -> UIColor {
        return UIColor.blue1
    }

    func buttonBackground() -> UIColor {
        return ThemeService.shared.theme.contentBackgroundColor
    }
    
    func configurePill(_ pillView: PillView) {
    }
    
    func configurePromoMenuView(view: PromoMenuView) {
        view.canClose = true
        view.backgroundColor = backgroundColor()
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
