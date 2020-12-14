//
//  PromotionInfoViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

class PromotionInfoViewController: BaseUIViewController {
    
    private let configRepository = ConfigRepository()
    
    var promotion: HabiticaPromotion?
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var promoBanner: PromoBannerView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var promptButton: UIButton!
    @IBOutlet private weak var instructionsTitleLabel: UILabel!
    @IBOutlet private weak var instructionsDescriptionLabel: UILabel!
    @IBOutlet private weak var limitationsTitleLabel: UILabel!
    @IBOutlet private weak var limitationsDescriptionLabel: UILabel!
    
    var instructionsDescription: String? {
        get {
            return instructionsDescriptionLabel.text
        }
        set {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            paragraphStyle.alignment = .center
            let attrString = NSMutableAttributedString(string: newValue ?? "")
            attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            instructionsDescriptionLabel.attributedText = attrString
        }
    }
    
var limitationsDescription: String? {
        get {
            return limitationsDescriptionLabel.text
        }
        set {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            paragraphStyle.alignment = .center
            let attrString = NSMutableAttributedString(string: newValue ?? "")
            attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            limitationsDescriptionLabel.attributedText = attrString
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        promotion = configRepository.activePromotion()
        
        instructionsTitleLabel.text = L10n.promoInfoInstructionsTitle
        limitationsTitleLabel.text = L10n.promoInfoLimitationsTitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainStackView.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 16, right: 20)
        mainStackView.isLayoutMarginsRelativeArrangement = true
        
        promotion?.configureInfoView(self)
        
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.shadowColor = .clear
            navigationController?.navigationBar.compactAppearance?.shadowColor = .clear
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if promotion == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        navigationController?.navigationBar.shadowImage = UIImage()
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.backgroundColor = theme.contentBackgroundColor
        } else {
            navigationController?.navigationBar.backgroundColor = theme.contentBackgroundColor
        }
        instructionsTitleLabel.textColor = theme.secondaryTextColor
        limitationsTitleLabel.textColor = theme.secondaryTextColor
        instructionsDescriptionLabel.textColor = theme.quadTextColor
        limitationsDescriptionLabel.textColor = theme.quadTextColor
    }
    
    @IBAction func promptButtonTapped(_ sender: Any) {
        guard let promo = promotion else {
            return
        }
        if promo.promoType == .gemsAmount || promo.promoType == .gemsPrice {
            perform(segue: StoryboardSegue.Main.purchaseGemsSegue)
        } else if promo.promoType == .subscription {
            if promo.identifier == "g1g1" {
                showGiftSubscriptionAlert()
            } else {
                perform(segue: StoryboardSegue.Main.subscriptionSegue)
            }
        }
    }
    
    private var giftRecipientUsername = ""

    private func showGiftSubscriptionAlert() {
        let alertController = HabiticaAlertController(title: L10n.giftRecipientTitle, message: L10n.giftRecipientSubtitle)
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.borderColor = UIColor.gray300
        textField.borderWidth = 1
        textField.tintColor = ThemeService.shared.theme.tintColor
        alertController.contentView = textField
        alertController.addAction(title: L10n.continue, style: .default, isMainAction: true, closeOnTap: true, handler: { _ in
            if let username = textField.text, username.isEmpty == false {
                let navigationController = StoryboardScene.Main.giftSubscriptionNavController.instantiate()
                if let giftViewController = navigationController.topViewController as? GiftSubscriptionViewController {
                    giftViewController.giftRecipientUsername = username
                }
                self.present(navigationController, animated: true, completion: nil)
            }
        })
        alertController.addCancelAction()
        alertController.containerViewSpacing = 8
        alertController.show()
        textField.becomeFirstResponder()
    }

}
