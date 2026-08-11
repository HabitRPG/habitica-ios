//
//  GiftOneGetOnePromotion.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.08.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//
import UIKit

class GiftOneGetOnePromotion: HabiticaPromotion {

    var identifier = "g1g1"
    var promoType: HabiticaPromotionType = .subscription
    var isWebPromo: Bool = false
    var startDate: Date
    var endDate: Date
    
    var pinnedPillTitle: String? { return nil }
    var pinnedPillTitleImage: UIImage? { return nil }
    var pinnedPillLeftArt: UIImage? { return nil }
    var pinnedPillBackground: UIColor? { return backgroundColor }
    var pinnedPillArrowColor: UIColor { return .yellow500 }
    var pinnedPillArtHeight: CGFloat { return 40 }
    
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
    
    init(startDate: Date?, endDate: Date?) {
        self.startDate = startDate ?? Date.with(year: 2020, month: 12, day: 17, timezone: TimeZone(abbreviation: "UTC"))
        self.endDate = endDate ?? Date.with(year: 2021, month: 1, day: 7, timezone: TimeZone(abbreviation: "UTC"))
    }
    
    var backgroundColor: UIColor {
        return UIColor("#925CF3")
    }

    var buttonBackground: UIColor {
        return ThemeService.shared.theme.contentBackgroundColor
    }
    
    var gradientStart: UIColor? {
        return UIColor("#3BCAD7")
    }
    var gradientEnd: UIColor? {
        return UIColor("#925CF3")
    }
    
    private func makeGradient(view: UIView) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()

        gradient.colors = [gradientStart?.cgColor ?? CGColor(gray: 0, alpha: 1), gradientEnd?.cgColor ?? CGColor(gray: 0, alpha: 1)]
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
        view.leftImageView.image = Asset.promoGiftLeftLarge.image
        view.rightImageView.image = Asset.promoGiftRightLarge.image
        view.setTitle(L10n.giftOneGetOneEvent)
        view.setDescription(L10n.giftOneGetOneDescription)
        view.actionButton.backgroundColor = buttonBackground
        view.actionButton.setTitle(L10n.learnMore, for: .normal)
        if ThemeService.shared.theme.isDark {
            view.actionButton.setTitleColor(UIColor.teal100, for: .normal)
            view.titleView.textColor = .white
            view.descriptionView.textColor = .white
        } else {
            view.actionButton.setTitleColor(UIColor.teal10, for: .normal)
            view.titleView.textColor = .blue1
            view.descriptionView.textColor = .blue1
        }
    }
    
    func configurePurchaseBanner(view: PromoBannerView) {
        view.backgroundColor = nil
        view.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let gradientLayer = makeGradient(view: view)
        view.layer.insertSublayer(gradientLayer, at: 0)
        view.leftImageView.image = Asset.subScreenG1g1PresentsLeft.image
        view.rightImageView.image = Asset.subScreenG1g1PresentsRight.image
        view.setTitle(L10n.GiftOneGetOneData.purchaseBannerTitle(shortDateFormatter.string(from: endDate)))
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
        viewController.promoBanner.setDuration(L10n.xToY(shortDateFormatter.string(from: startDate), shortDateFormatter.string(from: endDate)))
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
        viewController.limitationsDescription = L10n.GiftOneGetOneData.infoLimitations(fullDateFormatter.string(from: startDate),
                                                                                       fullDateFormatter.string(from: endDate))
    }
}
