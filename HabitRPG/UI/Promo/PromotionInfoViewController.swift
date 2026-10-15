//
//  PromotionInfoViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import UIKit

class PromotionInfoViewController: BaseUIViewController {
    
    private let configRepository = ConfigRepository.shared
    
    var promotion: HabiticaPromotion?
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var promoBanner: PromoBannerView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var promptButton: UIButton!
    @IBOutlet private weak var instructionsTitleLabel: UILabel!
    @IBOutlet weak var instructionsDescriptionLabel: UILabel!
    @IBOutlet private weak var limitationsTitleLabel: UILabel!
    @IBOutlet weak var limitationsDescriptionLabel: UILabel!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var textLineSpacing: CGFloat = 3
    var promptHorizontalInset: CGFloat = 0
    var descriptionHorizontalInset: CGFloat = 0
    
    var promptText: String? {
        get {
            return promptLabel.text
        }
        set {
            promptLabel.attributedText = centeredText(newValue, inset: promptHorizontalInset)
        }
    }
    
    var instructionsDescription: String? {
        get {
            return instructionsDescriptionLabel.text
        }
        set {
            instructionsDescriptionLabel.attributedText = centeredText(newValue, inset: descriptionHorizontalInset)
        }
    }
    
    var limitationsDescription: String? {
        get {
            return limitationsDescriptionLabel.text
        }
        set {
            limitationsDescriptionLabel.attributedText = centeredText(newValue, inset: descriptionHorizontalInset)
        }
    }
    
    private func centeredText(_ text: String?, inset: CGFloat) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = textLineSpacing
        paragraphStyle.alignment = .center
        paragraphStyle.firstLineHeadIndent = inset
        paragraphStyle.headIndent = inset
        paragraphStyle.tailIndent = -inset
        return NSAttributedString(string: text ?? "", attributes: [.paragraphStyle: paragraphStyle])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #unavailable(iOS 26.0) {
            navigationItem.rightBarButtonItem?.style = .done
        }
        
        promotion = configRepository.activePromotion()
        
        instructionsTitleLabel.text = L10n.promoInfoInstructionsTitle
        limitationsTitleLabel.text = L10n.promoInfoLimitationsTitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainStackView.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 16, right: 20)
        mainStackView.isLayoutMarginsRelativeArrangement = true
        
        promotion?.configureInfoView(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        promptButton.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.frame = promptButton.bounds }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if promotion == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        instructionsTitleLabel.textColor = .white
        limitationsTitleLabel.textColor = .white
        instructionsDescriptionLabel.textColor = .gray500
        limitationsDescriptionLabel.textColor = .gray500
        view.backgroundColor = .blackPurple50
        promptButton.cornerRadius = promptButton.frame.height / 2
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
        let alertController = GiftingAlertController(title: L10n.giftSubscription, message: L10n.giftGemsAlertText) { username in
            RouterHandler.shared.handle(.giftSubscription(username: username))
        }
        alertController.show()
    }

}
