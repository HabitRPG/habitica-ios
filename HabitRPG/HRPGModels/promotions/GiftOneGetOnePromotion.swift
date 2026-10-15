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
    
    var pinnedPillTitle: String? { return L10n.giftOneGetOneTitle }
    var pinnedPillTitleImage: UIImage? { return nil }
    var pinnedPillLeftArt: UIImage? { return Asset.g1g1PromoMini.image }
    var pinnedPillBackground: UIColor? { return nil }
    var pinnedPillArrowColor: UIColor { return .white }
    var pinnedPillArtHeight: CGFloat { return 40 }
    var pinnedPillArtInset: CGFloat { return 6 }
    var pinnedPillTitleSpacing: CGFloat { return 13 }
    
    // Optimize: Reuse DateFormatter instance to avoid expensive creation
    private lazy var shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    private lazy var utcTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private lazy var ordinalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }()
    
    private func limitationsDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMMdjmmz")
        if formatter.locale.language.languageCode == .english,
           let ordinal = ordinalFormatter.string(from: NSNumber(value: Calendar.current.component(.day, from: date))) {
            formatter.dateFormat = formatter.dateFormat.replacingOccurrences(of: "d", with: "'\(ordinal)'")
        }
        return "\(formatter.string(from: date)) (\(utcTimeFormatter.string(from: date)) UTC)"
    }
    
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
        view.setCardGradient(startColor: gradientStart ?? backgroundColor, endColor: gradientEnd ?? backgroundColor)
        view.leftImageView.image = Asset.promoGiftLeftLarge.image
        view.rightImageView.image = Asset.promoGiftRightLarge.image
        view.durationView.isHidden = true
        view.cardTopPadding = 13
        view.textGap = 1
        view.buttonGap = 8
        view.setTitle(L10n.giftOneGetOneTitle,
                      font: .systemFont(ofSize: 20, weight: .semibold),
                      color: .white,
                      lineHeight: 25)
        view.setDescription(L10n.giftOneGetOneDescription,
                            font: .systemFont(ofSize: 13, weight: .semibold),
                            color: .white,
                            lineHeight: 18,
                            maxLines: 2)
        view.actionButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.setActionTitle(L10n.viewOffer)
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
        viewController.promoBanner.titleTopMargin = 19
        viewController.promoBanner.descriptionTopMargin = 4
        viewController.promoBanner.durationTopMargin = 10
        viewController.promoBanner.setTitle(L10n.giftOneGetOneTitle)
        viewController.promoBanner.titleView.textColor = .white
        viewController.promoBanner.descriptionLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 10)
        viewController.promoBanner.setDescription(L10n.limitedEvent.uppercased())
        viewController.promoBanner.descriptionLabel.textColor = .white
        viewController.promoBanner.durationLabel.textColor = .white
        viewController.promoBanner.durationLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15, ofWeight: .semibold)
        viewController.promoBanner.setDuration(L10n.xToY(shortDateFormatter.string(from: startDate), shortDateFormatter.string(from: endDate)))
        viewController.textLineSpacing = 2
        viewController.promptHorizontalInset = 10
        viewController.descriptionHorizontalInset = 5
        viewController.promptLabel.textColor = .white
        viewController.promptText = L10n.GiftOneGetOneData.infoPrompt
        viewController.promptButton.setTitle(L10n.giftSubscription, for: .normal)
        viewController.promptButton.setTitleColor(.white, for: .normal)
        viewController.promptButton.backgroundColor = nil
        viewController.promptButton.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        viewController.promptButton.layer.insertSublayer(makeGradient(view: viewController.promptButton), at: 0)
        viewController.instructionsDescription = L10n.GiftOneGetOneData.infoInstructions
        viewController.limitationsDescription = L10n.GiftOneGetOneData.infoLimitations(limitationsDateString(startDate),
                                                                                       limitationsDateString(endDate))
        viewController.instructionsDescriptionLabel.textColor = .gray400
        viewController.limitationsDescriptionLabel.textColor = .gray400
        viewController.mainStackView.layoutMargins = UIEdgeInsets(top: 32, left: 16, bottom: 16, right: 16)
        viewController.mainStackView.setCustomSpacing(30, after: viewController.promptButton)
    }
}
